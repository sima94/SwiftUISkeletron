//
//  LoginViewModel.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 8.5.25..
//

import Foundation
import FormValidator
import Infuse

@MainActor
@Observable
final class LoginViewModel {

	// MARK: - Events

	enum Event {
		case loginSucceeded
		case showRegister
	}

	private let eventContinuation: AsyncStream<Event>.Continuation
	let events: AsyncStream<Event>

	// MARK: - State

	@ObservationIgnored
	@FormField(rules: [Rules.required()])
	var username: String = ""

	@ObservationIgnored
	@FormField(rules: [Rules.required(), Rules.password()], autoValidate: true)
	var password: String = ""

	var isLoginInProgress: Bool = false

	@ObservationIgnored
	var formValidator = FormValidator()

	@ObservationIgnored
	@Dependency(LoginStateKey.self) var loginState

	@ObservationIgnored
	@Dependency(AuthServiceKey.self) var authenticationService

	// MARK: - Init

	init() {
		var continuation: AsyncStream<Event>.Continuation!
		events = AsyncStream { continuation = $0 }
		eventContinuation = continuation
	}

	// MARK: - Actions

	func login() async {
		guard !isLoginInProgress else { return }
		guard formValidator.validate(in: self) else { return }
		isLoginInProgress = true
		defer { isLoginInProgress = false }
		do {
			try await authenticationService.loginUser(username: username, password: password)
			DependencyValues.shared.endFlow(.authentication)
			eventContinuation.yield(.loginSucceeded)
		} catch {
			log.debug("Login error: \(error)")
		}
	}

	func registerTapped() {
		eventContinuation.yield(.showRegister)
	}
}
