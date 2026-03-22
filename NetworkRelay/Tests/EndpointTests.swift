//
//  EndpointTests.swift
//  NetworkRelayTests
//

import Testing
@testable import NetworkRelay

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
