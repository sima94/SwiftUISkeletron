//
//  AuthenticationService.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 27.5.25..
//

import Foundation
import Infuse
import NetworkRelay

// MARK: - Flow ID

extension FlowID {
	static let authentication: FlowID = "authentication"
}

// MARK: - Dependency Key

struct AuthServiceKey: DependencyKey {
	static var scope: DependencyScope { .flow(.authentication) }
	static var liveValue: any AuthenticationServiceProtocol {
		return AuthenticationService()
	}
	static var testValue: any AuthenticationServiceProtocol {
		MockAuthenticationService()
	}
}

// MARK: - AuthenticationService

final class AuthenticationService: AuthenticationServiceProtocol, Sendable {

	let userSession: any UserSessionProtocol
	let networkService: any NetworkingServiceProtocol

	init() {
		@Dependency(UnauthorizedNetworkServiceKey.self) var networkService
		@Dependency(UserSessionKey.self) var userSession
		self.networkService = networkService
		self.userSession = userSession
	}

	func registerUser(_ user: RegisterUser) async throws {
		let registerRequest = try RegisterRequest(registerUser: user)
		try await networkService.execute(registerRequest)
	}

	func loginUser(username: String, password: String) async throws {
		let loginUser = LoginUser(username: username, password: password)
		let loginRequest = try LoginRequest(loginUser: loginUser)
		let response = try await networkService.fetchRequest(loginRequest)
		await userSession.setToken(OAuthToken(accessToken: response.token, refreshToken: response.refreshToken))
	}
}

// MARK: - Mock

final class MockAuthenticationService: AuthenticationServiceProtocol, Sendable {
	func registerUser(_ user: RegisterUser) async throws {}
	func loginUser(username: String, password: String) async throws {}
}
