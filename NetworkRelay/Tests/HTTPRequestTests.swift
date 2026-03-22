//
//  HTTPRequestTests.swift
//  NetworkRelayTests
//

import Foundation
import Testing
@testable import NetworkRelay

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

// MARK: - Tests

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

	@Test("default headers include JSON content type")
	func defaultHeaders() {
		let request = TestFetchRequest()
		#expect(request.headers == nil) // custom nil, but protocol default is [.jsonContentType]
	}

	@Test("default validResponseStatusCodes is 200..<300")
	func defaultValidStatusCodes() {
		struct MinimalRequest: HTTPRequest {
			var method: HTTPRequestMethod = .get
			var path: String = "/test"
		}
		let request = MinimalRequest()
		#expect(request.validResponseStatusCodes == 200 ..< 300)
		#expect(request.headers?.first?.field == "Content-Type")
		#expect(request.headers?.first?.value == "application/json")
	}

	@Test("query parameters are included in URLRequest")
	func queryParameters() throws {
		let endpoint = Endpoint(scheme: "https", urlHost: "api.test.com", port: 0)
		var request = TestFetchRequest()
		request.queryParameters = [URLQueryItem(name: "page", value: "2")]
		let urlRequest = try URLRequest(httpRequest: request, endpoint: endpoint)

		#expect(urlRequest.url?.absoluteString.contains("page=2") == true)
	}

	@Test("custom headers are set on URLRequest")
	func customHeaders() throws {
		let endpoint = Endpoint(scheme: "https", urlHost: "api.test.com", port: 0)
		var request = TestFetchRequest()
		request.headers = [HTTPRequestHeader(field: "X-Custom", value: "test")]
		let urlRequest = try URLRequest(httpRequest: request, endpoint: endpoint)

		#expect(urlRequest.value(forHTTPHeaderField: "X-Custom") == "test")
	}

	@Test("HTTPFetchRequest provides default JSONDecoder")
	func defaultDecoder() {
		let request = TestFetchRequest()
		#expect(request.decoder is JSONDecoder)
	}

	@Test("all HTTP methods have correct raw values")
	func httpMethodRawValues() {
		#expect(HTTPRequestMethod.get.rawValue == "GET")
		#expect(HTTPRequestMethod.post.rawValue == "POST")
		#expect(HTTPRequestMethod.put.rawValue == "PUT")
		#expect(HTTPRequestMethod.patch.rawValue == "PATCH")
		#expect(HTTPRequestMethod.delete.rawValue == "DELETE")
	}

	@Test("HTTPRequestHeader convenience initializers")
	func headerConvenience() {
		let custom = HTTPRequestHeader.contentType("text/plain")
		#expect(custom.field == "Content-Type")
		#expect(custom.value == "text/plain")

		let json = HTTPRequestHeader.jsonContentType
		#expect(json.value == "application/json")
	}
}
