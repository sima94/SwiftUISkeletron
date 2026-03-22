//
//  NetworkRelayTests.swift
//  NetworkRelayTests
//

import Foundation
import Testing
@testable import NetworkRelay

// MARK: - Endpoint Tests

@Suite("Endpoint")
struct EndpointTests {

	@Test("constructs URL with port")
	func urlWithPort() {
		let endpoint = Endpoint(scheme: "http", urlHost: "localhost", port: 8080)
		let url = endpoint.url(for: "api/v1/test")
		#expect(url?.absoluteString == "http://localhost:8080/api/v1/test")
	}

	@Test("constructs URL without port when zero")
	func urlWithoutPort() {
		let endpoint = Endpoint(scheme: "https", urlHost: "api.example.com", port: 0)
		let url = endpoint.url(for: "/api/v1/test")
		#expect(url?.absoluteString == "https://api.example.com/api/v1/test")
	}

	@Test("prepends slash to path if missing")
	func prependsSlash() {
		let endpoint = Endpoint(scheme: "https", urlHost: "example.com", port: 0)
		let url = endpoint.url(for: "path")
		#expect(url?.path().hasPrefix("/") == true)
	}
}

// MARK: - Test Fixtures

struct TestFetchRequest: HTTPFetchRequest {
	typealias Object = [String]
	var method: HTTPRequestMethod = .get
	var path: String = "api/test"
	var queryParameters: [URLQueryItem]?
	var body: Data?
	var headers: [HTTPRequestHeader]?
	var validResponseStatusCodes: Range<Int>? = 200 ..< 300
}

struct TestPostRequest: HTTPRequest {
	var method: HTTPRequestMethod = .post
	var path: String = "api/submit"
	var queryParameters: [URLQueryItem]?
	var body: Data?
	var headers: [HTTPRequestHeader]?
	var validResponseStatusCodes: Range<Int>? = 201 ..< 202
}

// MARK: - HTTPRequest Tests

@Suite("HTTPRequest")
struct HTTPRequestTests {

	@Test("defaults are set correctly")
	func requestDefaults() {
		let request = TestFetchRequest()
		#expect(request.method == .get)
		#expect(request.queryParameters == nil)
		#expect(request.body == nil)
	}

	@Test("URLRequest is constructed from HTTPRequest")
	func urlRequestConstruction() throws {
		let endpoint = Endpoint(scheme: "https", urlHost: "api.test.com", port: 0)
		var request = TestPostRequest()
		request.body = "{}".data(using: .utf8)
		let urlRequest = try URLRequest(httpRequest: request, endpoint: endpoint)

		#expect(urlRequest.httpMethod == "POST")
		#expect(urlRequest.url?.path().contains("api/submit") == true)
		#expect(urlRequest.httpBody == "{}".data(using: .utf8))
	}
}

// MARK: - NetworkingError Tests

@Suite("NetworkingError")
struct NetworkingErrorTests {

	@Test("error descriptions are set")
	func errorDescriptions() {
		#expect(NetworkingError.invalidURL.errorDescription == "Invalid URL")
		#expect(NetworkingError.invalidResponse.errorDescription == "Invalid response from server")
		#expect(NetworkingError.noData.errorDescription == "No data received")
		#expect(NetworkingError.httpError(statusCode: 404, data: nil).errorDescription == "HTTP error: 404")
	}
}
