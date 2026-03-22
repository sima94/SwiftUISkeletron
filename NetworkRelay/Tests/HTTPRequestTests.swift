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
}
