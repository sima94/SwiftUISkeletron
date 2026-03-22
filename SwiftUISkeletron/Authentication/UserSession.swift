//
//  UserSession.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 8.5.25..
//

import Foundation
import Infuse
import NetworkRelay

protocol UserSessionProtocol: Sendable, RequestAdapter {
	var currentToken: OAuthToken? { get async }
	func setToken(_ token: OAuthToken?) async
	func tokenStream() async -> AsyncStream<OAuthToken?>
}

// MARK: - Dependency Key

struct UserSessionKey: DependencyKey {
	static var liveValue: any UserSessionProtocol { UserSession() }
	static var testValue: any UserSessionProtocol { MockUserSession() }
}

// MARK: - Mock (for tests)

actor MockUserSession: UserSessionProtocol {
	private var token: OAuthToken?

	var currentToken: OAuthToken? { token }

	func setToken(_ token: OAuthToken?) {
		self.token = token
	}

	func tokenStream() -> AsyncStream<OAuthToken?> {
		AsyncStream { $0.yield(nil) }
	}

	nonisolated func adapt(_ urlRequest: URLRequest, for session: URLSession) async -> URLRequest {
		urlRequest
	}
}

// MARK: - UserSession

actor UserSession: UserSessionProtocol {

	private let keychain = Keychain<OAuthToken>(key: "token")

	private var token: OAuthToken?
	private var continuations: [UUID: AsyncStream<OAuthToken?>.Continuation] = [:]

	init() {
		self.token = keychain.wrappedValue
	}

	var currentToken: OAuthToken? { token }

	func setToken(_ newToken: OAuthToken?) {
		token = newToken
		keychain.wrappedValue = newToken
		for (_, continuation) in continuations {
			continuation.yield(newToken)
		}
	}

	func tokenStream() -> AsyncStream<OAuthToken?> {
		let currentToken = token
		return AsyncStream { continuation in
			let id = UUID()
			continuation.yield(currentToken)
			self.continuations[id] = continuation
			continuation.onTermination = { [weak self] _ in
				Task { await self?.removeContinuation(id) }
			}
		}
	}

	private func removeContinuation(_ id: UUID) {
		continuations[id] = nil
	}

	nonisolated func adapt(_ urlRequest: URLRequest, for session: URLSession) async -> URLRequest {
		var urlRequest = urlRequest
		let token = await currentToken
		urlRequest.allHTTPHeaderFields?["Authorization"] = "Bearer \(token?.refreshToken ?? "")"
		return urlRequest
	}
}
