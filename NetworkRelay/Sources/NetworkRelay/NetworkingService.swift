//
//  NetworkingService.swift
//  NetworkRelay
//

import Foundation

/// Concrete networking service that executes HTTP requests with adapter/retrier support.
public final class NetworkingService: NetworkingServiceProtocol, @unchecked Sendable {

	private let session: URLSession
	private let endpoint: Endpoint
	private let requestAdapter: (any RequestAdapter)?
	private let requestRetrier: (any RequestRetrier)?
	private let logger: (@Sendable (String) -> Void)?

	public init(
		session: URLSession,
		endpoint: Endpoint,
		requestAdapter: (any RequestAdapter)?,
		requestRetrier: (any RequestRetrier)?,
		logger: (@Sendable (String) -> Void)? = nil
	) {
		self.session = session
		self.endpoint = endpoint
		self.requestAdapter = requestAdapter
		self.requestRetrier = requestRetrier
		self.logger = logger
	}

	// MARK: - NetworkingServiceProtocol

	public func fetchRequest<R: HTTPFetchRequest>(_ request: R) async throws -> R.Object {
		let (data, _) = try await execute(request)
		do {
			return try request.decoder.decode(R.Object.self, from: data)
		} catch {
			throw NetworkingError.decodingError(error)
		}
	}

	@discardableResult
	public func execute<R: HTTPRequest>(_ request: R) async throws -> (Data, HTTPURLResponse) {
		var urlRequest = try URLRequest(httpRequest: request, endpoint: endpoint)

		logger?("[\(request.method.rawValue)] \(urlRequest.url?.absoluteString ?? "")")

		// Apply adapter
		if let adapter = requestAdapter {
			urlRequest = await adapter.adapt(urlRequest, for: session)
		}

		// Execute
		let (data, response) = try await session.data(for: urlRequest)

		guard let httpResponse = response as? HTTPURLResponse else {
			throw NetworkingError.invalidResponse
		}

		// Check for retry
		if let validRange = request.validResponseStatusCodes, !validRange.contains(httpResponse.statusCode) {
			if let retrier = requestRetrier {
				let error = NetworkingError.httpError(statusCode: httpResponse.statusCode, data: data)
				let shouldRetry = await retrier.retry(urlRequest, httpUrlResponse: httpResponse, for: session, dueTo: error)
				if shouldRetry {
					return try await execute(request)
				}
			}
			throw NetworkingError.httpError(statusCode: httpResponse.statusCode, data: data)
		}

		return (data, httpResponse)
	}
}
