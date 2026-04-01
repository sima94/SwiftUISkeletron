//
//  LoginManager.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 8.5.25..
//

import Foundation
import Infuse
import NetworkRelay

// MARK: - Dependency Keys

struct LoginStateKey: DependencyKey {
	static var liveValue: LoginState {
		@Dependency(\.userSession) var userSession
		return LoginState(userSession: userSession)
	}
	static var testValue: LoginState {
		LoginState(userSession: MockUserSession())
	}
}

struct TokenRetrierKey: DependencyKey {
	static var liveValue: TokenRetrier {
		@Dependency(\.userSession) var userSession
		return TokenRetrier(userSession: userSession)
	}
	static var testValue: TokenRetrier {
		TokenRetrier(userSession: MockUserSession())
	}
}

extension DependencyValues {
	var loginState: LoginState {
		get { self[LoginStateKey.self] }
		set { self[LoginStateKey.self] = newValue }
	}

	var tokenRetrier: TokenRetrier {
		get { self[TokenRetrierKey.self] }
		set { self[TokenRetrierKey.self] = newValue }
	}
}

// MARK: - LoginState (UI-facing, @MainActor)

@MainActor
@Observable
final class LoginState {

	var isLoggedIn: Bool = false

	@ObservationIgnored
	let userSession: any UserSessionProtocol

	@ObservationIgnored
	private var tokenTask: Task<Void, Never>?

	nonisolated init(userSession: any UserSessionProtocol) {
		self.userSession = userSession
	}

	func startObserving() {
		guard tokenTask == nil else { return }
		tokenTask = Task { [weak self] in
			guard let session = self?.userSession else { return }
			for await token in await session.tokenStream() {
				self?.isLoggedIn = token != nil
			}
		}
	}

	deinit {
		tokenTask?.cancel()
	}

	func logout() async {
		await userSession.setToken(nil)
	}
}

// MARK: - TokenRetrier (Sendable, for networking layer)

final class TokenRetrier: RequestRetrier, Sendable {

	let userSession: any UserSessionProtocol
	let networkingService: NetworkingServiceProtocol

	init(userSession: any UserSessionProtocol) {
		self.userSession = userSession
		@Dependency(\.unauthorizedNetworkService) var networkingService
		self.networkingService = networkingService
	}

	func retry(_ request: URLRequest, httpUrlResponse: HTTPURLResponse, for session: URLSession, dueTo error: any Error) async -> Bool {
		if httpUrlResponse.statusCode == 401 {
			// refresh token and return true
			// let token net.fetchRequest(RefreshToken)
			// userSession.setToken(<#T##token: OAuthToken?##OAuthToken?#>)
			return true
		}
		return false
	}
}
