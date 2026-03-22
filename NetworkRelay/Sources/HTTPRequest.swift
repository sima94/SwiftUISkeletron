//
//  HTTPRequest.swift
//  NetworkRelay
//

import Foundation

// MARK: - HTTP Method

public enum HTTPRequestMethod: String, Sendable {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case patch = "PATCH"
	case delete = "DELETE"
}

// MARK: - HTTP Header

public struct HTTPRequestHeader: Sendable {
	public let field: String
	public let value: String

	public init(field: String, value: String) {
		self.field = field
		self.value = value
	}

	public static func contentType(_ value: String) -> HTTPRequestHeader {
		HTTPRequestHeader(field: "Content-Type", value: value)
	}

	public static let jsonContentType = HTTPRequestHeader.contentType("application/json")
}

// MARK: - HTTPRequest Protocol

/// Base protocol for HTTP requests that return raw (Data, HTTPURLResponse).
public protocol HTTPRequest: Sendable {
	var method: HTTPRequestMethod { get }
	var path: String { get }
	var queryParameters: [URLQueryItem]? { get }
	var body: Data? { get }
	var headers: [HTTPRequestHeader]? { get }
	var validResponseStatusCodes: Range<Int>? { get }
}

public extension HTTPRequest {
	var queryParameters: [URLQueryItem]? { nil }
	var body: Data? { nil }
	var headers: [HTTPRequestHeader]? { [.jsonContentType] }
	var validResponseStatusCodes: Range<Int>? { 200 ..< 300 }
}

// MARK: - HTTPFetchRequest Protocol

/// Extended protocol for requests that decode a `Decodable` response.
public protocol HTTPFetchRequest: HTTPRequest {
	associatedtype Object: Decodable & Sendable
	var decoder: JSONDecoder { get }
}

public extension HTTPFetchRequest {
	var decoder: JSONDecoder { JSONDecoder() }
}
