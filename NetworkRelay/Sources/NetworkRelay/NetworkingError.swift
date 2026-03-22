//
//  NetworkingError.swift
//  NetworkRelay
//

import Foundation

/// Errors that can occur during networking operations.
public enum NetworkingError: Error, LocalizedError, Sendable {
	case invalidURL
	case invalidResponse
	case httpError(statusCode: Int, data: Data?)
	case decodingError(Error)
	case noData
	case unknown(Error)

	public var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "Invalid URL"
		case .invalidResponse:
			return "Invalid response from server"
		case .httpError(let statusCode, _):
			return "HTTP error: \(statusCode)"
		case .decodingError(let error):
			return "Decoding error: \(error.localizedDescription)"
		case .noData:
			return "No data received"
		case .unknown(let error):
			return error.localizedDescription
		}
	}
}
