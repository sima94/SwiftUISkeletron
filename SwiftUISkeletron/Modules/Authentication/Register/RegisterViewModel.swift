//
//  RegisterViewModel.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 8.5.25..
//

import Foundation
import FormValidator
import Infuse

@MainActor
@Observable
final class RegisterViewModel {

	// MARK: - Events

	enum Event {
		case registerSucceeded
	}

	private let eventContinuation: AsyncStream<Event>.Continuation
	let events: AsyncStream<Event>

	// MARK: - State

	@ObservationIgnored
	@FormField(rules: [Rules.required()])
	var username: String = ""

	@ObservationIgnored
	@FormField(rules: [Rules.required()])
	var firstName: String = ""

	@ObservationIgnored
	@FormField(rules: [Rules.required()])
	var lastName: String = ""

	@ObservationIgnored
	@FormField(rules: [Rules.required(), Rules.password()], autoValidate: true)
	var password: String = ""

	@ObservationIgnored
	@FormField(rules: [Rules.required(), Rules.matchField(\RegisterViewModel._password, message: "Passwords do not match")], autoValidate: true)
	var confirmPassword: String = ""

	@ObservationIgnored
	@FormField(rules: [Rules.required(), Rules.email()], autoValidate: true)
	var email: String = ""

	var isLoading: Bool = false

	@ObservationIgnored
	var formValidator = FormValidator()

	@ObservationIgnored
	@Dependency(AuthServiceKey.self) var authenticationService

	// MARK: - Init

	init() {
		var continuation: AsyncStream<Event>.Continuation!
		events = AsyncStream { continuation = $0 }
		eventContinuation = continuation
	}

	// MARK: - Actions

	func register() async {
		guard !isLoading else { return }
		guard formValidator.validate(in: self) else { return }
		isLoading = true
		defer { isLoading = false }

		do {
			try await authenticationService.registerUser(.init(username: username, firstName: firstName, lastName: lastName, email: email, password: password))
			eventContinuation.yield(.registerSucceeded)
		} catch {
			log.debug("Register error: \(error)")
		}
	}
}
