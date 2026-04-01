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

	@ObservationIgnored
	@FormField(
		rules: [Rules.required(), Rules.minLength(10, message: "Phone number is too short")],
		autoValidate: true,
		formatter: PhoneFormatter(pattern: "+### ## ### ####")
	)
	var phone: String = ""

	@ObservationIgnored
	@FormField(
		rules: [Rules.required(), Rules.regex("^[A-Z]{2}\\d{2}[A-Z0-9]{4,30}$", message: "Invalid IBAN")],
		autoValidate: true,
		formatter: IBANFormatter()
	)
	var iban: String = ""

	@ObservationIgnored
	@FormField(
		rules: [Rules.required(), Rules.custom(message: "Amount must be greater than 0") { Double($0).map { $0 > 0 } ?? false }],
		autoValidate: true,
		formatter: AmountFormatter()
	)
	var amount: String = ""

	var isLoading: Bool = false

	@ObservationIgnored
	var formValidator = FormValidator()

	@ObservationIgnored
	@Dependency(\.authenticationService) var authenticationService

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
