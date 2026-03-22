//
//  Endpoint.swift
//  NetworkRelay
//

import Foundation

/// Defines the base URL configuration for API requests.
public struct Endpoint: Sendable {

	public let scheme: String
	public let urlHost: String
	public let port: Int

	public init(scheme: String, urlHost: String, port: Int) {
		self.scheme = scheme
		self.urlHost = urlHost
		self.port = port
	}

	/// Constructs a full URL for the given path.
	public func url(for path: String) -> URL? {
		var components = URLComponents()
		components.scheme = scheme
		components.host = urlHost
		if port != 0 {
			components.port = port
		}
		components.path = path.hasPrefix("/") ? path : "/\(path)"
		return components.url
	}
}
