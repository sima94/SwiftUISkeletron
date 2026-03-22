//
//  URLRequest+Extensions.swift
//  NetworkRelay
//

import Foundation

extension URLRequest {

	/// Creates a URLRequest from an HTTPRequest and Endpoint.
	init<R: HTTPRequest>(httpRequest: R, endpoint: Endpoint) throws {
		guard let url = endpoint.url(for: httpRequest.path) else {
			throw NetworkingError.invalidURL
		}

		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
		components?.queryItems = httpRequest.queryParameters

		guard let finalURL = components?.url else {
			throw NetworkingError.invalidURL
		}

		self.init(url: finalURL)
		self.httpMethod = httpRequest.method.rawValue
		self.httpBody = httpRequest.body

		if let headers = httpRequest.headers {
			for header in headers {
				self.setValue(header.value, forHTTPHeaderField: header.field)
			}
		}
	}
}
