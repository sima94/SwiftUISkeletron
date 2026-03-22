//
//  DependencyKeys.swift
//  SwiftUISkeletron
//

import Infuse
import NetworkRelay
import Foundation

// MARK: - URLSession

struct URLSessionKey: DependencyKey {
	static var liveValue: URLSession {
		URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
	}
	static var testValue: URLSession {
		URLSession(configuration: .ephemeral)
	}
}

// MARK: - Endpoint

struct EndpointKey: DependencyKey {
	static var liveValue: Endpoint {
		Environment.default.endpoint
	}
	static var testValue: Endpoint {
		Endpoint(scheme: "https", urlHost: "test.localhost", port: 0)
	}
}

// MARK: - Networking

struct NetworkServiceKey: DependencyKey {
	static var liveValue: any NetworkingServiceProtocol {
		@Dependency(URLSessionKey.self) var session
		@Dependency(EndpointKey.self) var endpoint
		@Dependency(UserSessionKey.self) var userSession
		@Dependency(TokenRetrierKey.self) var tokenRetrier
		return NetworkingService(
			session: session,
			endpoint: endpoint,
			requestAdapter: userSession,
			requestRetrier: tokenRetrier,
			logger: { log.debug($0) }
		)
	}
	static var testValue: any NetworkingServiceProtocol {
		MockNetworkingService()
	}
}

struct UnauthorizedNetworkServiceKey: DependencyKey {
	static var liveValue: any NetworkingServiceProtocol {
		@Dependency(URLSessionKey.self) var session
		@Dependency(EndpointKey.self) var endpoint
		return NetworkingService(
			session: session,
			endpoint: endpoint,
			requestAdapter: nil,
			requestRetrier: nil,
			logger: { log.debug($0) }
		)
	}
	static var testValue: any NetworkingServiceProtocol {
		MockNetworkingService()
	}
}

// MARK: - Mock

final class MockNetworkingService: NetworkingServiceProtocol, Sendable {
	func fetchRequest<R: HTTPFetchRequest>(_ request: R) async throws -> R.Object {
		fatalError("MockNetworkingService.fetchRequest not stubbed")
	}

	func execute<R: HTTPRequest>(_ request: R) async throws -> (Data, HTTPURLResponse) {
		fatalError("MockNetworkingService.execute not stubbed")
	}
}
