//
//  NetworkingServiceProtocol.swift
//  NetworkRelay
//

import Foundation

/// Protocol for adapting outgoing requests (e.g., adding auth headers).
public protocol RequestAdapter: Sendable {
	func adapt(_ urlRequest: URLRequest, for session: URLSession) async -> URLRequest
}

/// Protocol for retrying failed requests (e.g., on 401 → refresh token).
public protocol RequestRetrier: Sendable {
	func retry(_ request: URLRequest, httpUrlResponse: HTTPURLResponse, for session: URLSession, dueTo error: any Error) async -> Bool
}

/// Main networking service protocol.
public protocol NetworkingServiceProtocol: Sendable {
	/// Executes a request and decodes the response into the expected type.
	func fetchRequest<R: HTTPFetchRequest>(_ request: R) async throws -> R.Object

	/// Executes a request and returns raw data and response.
	@discardableResult
	func execute<R: HTTPRequest>(_ request: R) async throws -> (Data, HTTPURLResponse)
}
