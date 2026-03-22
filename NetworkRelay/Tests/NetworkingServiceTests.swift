//
//  NetworkingServiceTests.swift
//  NetworkRelayTests
//

import Foundation
import Testing
@testable import NetworkRelay

// MARK: - Mock URLProtocol

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

	override class func canInit(with request: URLRequest) -> Bool { true }
	override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

	override func startLoading() {
		guard let handler = Self.requestHandler else {
			client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
			return
		}
		do {
			let (response, data) = try handler(request)
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			client?.urlProtocol(self, didLoad: data)
			client?.urlProtocolDidFinishLoading(self)
		} catch {
			client?.urlProtocol(self, didFailWithError: error)
		}
	}

	override func stopLoading() {}
}

// MARK: - Mock Adapter

private struct MockAdapter: RequestAdapter {
	let headerField: String
	let headerValue: String

	func adapt(_ urlRequest: URLRequest, for session: URLSession) async -> URLRequest {
		var request = urlRequest
		request.setValue(headerValue, forHTTPHeaderField: headerField)
		return request
	}
}

// MARK: - Mock Retrier

private final class MockRetrier: RequestRetrier, @unchecked Sendable {
	var retryCount = 0
	let maxRetries: Int

	init(maxRetries: Int = 1) {
		self.maxRetries = maxRetries
	}

	func retry(_ request: URLRequest, httpUrlResponse: HTTPURLResponse, for session: URLSession, dueTo error: any Error) async -> Bool {
		retryCount += 1
		return retryCount <= maxRetries
	}
}

// MARK: - Test Fixtures

private struct MockResponse: Codable, Sendable, Equatable {
	let id: Int
	let name: String
}

private struct MockFetchRequest: HTTPFetchRequest {
	typealias Object = MockResponse
	var method: HTTPRequestMethod = .get
	var path: String = "/api/mock"
}

private struct MockExecuteRequest: HTTPRequest {
	var method: HTTPRequestMethod = .get
	var path: String = "/api/data"
	var validResponseStatusCodes: Range<Int>? = 200 ..< 300
}

// MARK: - Helpers

private func makeSession() -> URLSession {
	let config = URLSessionConfiguration.ephemeral
	config.protocolClasses = [MockURLProtocol.self]
	config.requestCachePolicy = .reloadIgnoringLocalCacheData
	return URLSession(configuration: config)
}

/// Registers MockURLProtocol globally as a fallback.
private func registerMockProtocol() {
	URLProtocol.registerClass(MockURLProtocol.self)
}

private let testEndpoint = Endpoint(scheme: "https", urlHost: "api.test.com", port: 0)

private final class LogBox: @unchecked Sendable {
	var message: String?
}

// MARK: - Tests

@Suite("NetworkingService", .serialized)
struct NetworkingServiceTests {

	init() {
		registerMockProtocol()
	}

	@Test("execute returns data and response for valid request")
	func executeSuccess() async throws {
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(
				url: request.url!, statusCode: 200,
				httpVersion: nil, headerFields: nil
			)!
			return (response, Data("hello".utf8))
		}

		let service = NetworkingService(
			session: makeSession(), endpoint: testEndpoint,
			requestAdapter: nil, requestRetrier: nil
		)

		let (data, response) = try await service.execute(MockExecuteRequest())
		#expect(response.statusCode == 200)
		#expect(String(data: data, encoding: .utf8) == "hello")
	}

	@Test("execute throws httpError for invalid status code")
	func executeHTTPError() async {
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(
				url: request.url!, statusCode: 404,
				httpVersion: nil, headerFields: nil
			)!
			return (response, Data())
		}

		let service = NetworkingService(
			session: makeSession(), endpoint: testEndpoint,
			requestAdapter: nil, requestRetrier: nil
		)

		await #expect(throws: NetworkingError.self) {
			try await service.execute(MockExecuteRequest())
		}
	}

	@Test("fetchRequest decodes response into expected type")
	func fetchRequestDecodes() async throws {
		let expected = MockResponse(id: 1, name: "Test")
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(
				url: request.url!, statusCode: 200,
				httpVersion: nil, headerFields: nil
			)!
			let data = try! JSONEncoder().encode(expected)
			return (response, data)
		}

		let service = NetworkingService(
			session: makeSession(), endpoint: testEndpoint,
			requestAdapter: nil, requestRetrier: nil
		)

		let result = try await service.fetchRequest(MockFetchRequest())
		#expect(result == expected)
	}

	@Test("fetchRequest throws decodingError for invalid JSON")
	func fetchRequestDecodingError() async {
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(
				url: request.url!, statusCode: 200,
				httpVersion: nil, headerFields: nil
			)!
			return (response, Data("not json".utf8))
		}

		let service = NetworkingService(
			session: makeSession(), endpoint: testEndpoint,
			requestAdapter: nil, requestRetrier: nil
		)

		await #expect(throws: NetworkingError.self) {
			try await service.fetchRequest(MockFetchRequest())
		}
	}

	@Test("adapter adds headers to request")
	func adapterApplied() async throws {
		MockURLProtocol.requestHandler = { request in
			#expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
			let response = HTTPURLResponse(
				url: request.url!, statusCode: 200,
				httpVersion: nil, headerFields: nil
			)!
			return (response, Data())
		}

		let adapter = MockAdapter(headerField: "Authorization", headerValue: "Bearer token123")
		let service = NetworkingService(
			session: makeSession(), endpoint: testEndpoint,
			requestAdapter: adapter, requestRetrier: nil
		)

		try await service.execute(MockExecuteRequest())
	}

	@Test("retrier retries on failure then succeeds")
	func retrierRetries() async throws {
		var callCount = 0
		MockURLProtocol.requestHandler = { request in
			callCount += 1
			let statusCode = callCount == 1 ? 401 : 200
			let response = HTTPURLResponse(
				url: request.url!, statusCode: statusCode,
				httpVersion: nil, headerFields: nil
			)!
			return (response, Data("ok".utf8))
		}

		let retrier = MockRetrier(maxRetries: 1)
		let service = NetworkingService(
			session: makeSession(), endpoint: testEndpoint,
			requestAdapter: nil, requestRetrier: retrier
		)

		let (_, response) = try await service.execute(MockExecuteRequest())
		#expect(response.statusCode == 200)
		#expect(retrier.retryCount == 1)
	}

	@Test("logger is called with method and URL")
	func loggerCalled() async throws {
		MockURLProtocol.requestHandler = { request in
			let response = HTTPURLResponse(
				url: request.url!, statusCode: 200,
				httpVersion: nil, headerFields: nil
			)!
			return (response, Data())
		}

		let logBox = LogBox()
		let service = NetworkingService(
			session: makeSession(), endpoint: testEndpoint,
			requestAdapter: nil, requestRetrier: nil,
			logger: { logBox.message = $0 }
		)

		try await service.execute(MockExecuteRequest())
		#expect(logBox.message?.contains("[GET]") == true)
		#expect(logBox.message?.contains("api/data") == true)
	}
}
