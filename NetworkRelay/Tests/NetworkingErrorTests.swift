//
//  NetworkingErrorTests.swift
//  NetworkRelayTests
//

import Testing
@testable import NetworkRelay

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
