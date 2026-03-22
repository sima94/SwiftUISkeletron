//
//  FormValidatorTests.swift
//  FormValidator
//

import Testing
@testable import FormValidator

@Suite("FormValidator")
@MainActor
struct FormValidatorTests {

	@Test("All fields pass")
	func allFieldsPass() {
		let username = FormField(wrappedValue: "user", rules: [Rules.required()])
		let password = FormField(wrappedValue: "12345678", rules: [Rules.password()])

		let validator = FormValidator()
		validator.register(username)
		validator.register(password)

		#expect(validator.validate() == true)
		#expect(validator.isValid == true)
	}

	@Test("One field failing makes form invalid")
	func oneFieldFails() {
		let username = FormField(wrappedValue: "", rules: [Rules.required()])
		let password = FormField(wrappedValue: "12345678", rules: [Rules.password()])

		let validator = FormValidator()
		validator.register(username)
		validator.register(password)

		#expect(validator.validate() == false)
		#expect(username.error != nil)
		#expect(password.error == nil)
	}

	@Test("Validates ALL fields even when first fails")
	func validatesAllFields() {
		let field1 = FormField(wrappedValue: "", rules: [Rules.required(message: "F1")])
		let field2 = FormField(wrappedValue: "", rules: [Rules.required(message: "F2")])

		let validator = FormValidator()
		validator.register(field1)
		validator.register(field2)

		validator.validate()
		#expect(field1.error != nil)
		#expect(field2.error != nil)
	}

	@Test("Disabled field skipped during validation")
	func disabledFieldSkipped() {
		let valid = FormField(wrappedValue: "hello", rules: [Rules.required()])
		let invalid = FormField(wrappedValue: "", rules: [Rules.required()])
		invalid.isEnabled = false

		let validator = FormValidator()
		validator.register(valid)
		validator.register(invalid)

		#expect(validator.validate() == true)
	}

	@Test("Async validation runs after sync passes")
	func asyncValidation() async {
		let field = FormField(
			wrappedValue: "taken@email.com",
			rules: [Rules.required()],
			asyncRules: [
				Rules.asyncCustom(message: "Email taken") { (value: String) in
					value != "taken@email.com"
				}
			]
		)

		let validator = FormValidator()
		validator.register(field)

		#expect(await validator.validateAsync() == false)
		#expect(field.error?.message == "Email taken")
	}

	@Test("Async skipped when sync fails")
	func asyncSkippedWhenSyncFails() async {
		nonisolated(unsafe) var asyncCalled = false
		let field = FormField(
			wrappedValue: "",
			rules: [Rules.required()],
			asyncRules: [
				AnyAsyncValidationRule<String>(validate: { _ in
					asyncCalled = true
					return .success(())
				})
			]
		)

		let validator = FormValidator()
		validator.register(field)

		#expect(await validator.validateAsync() == false)
		#expect(asyncCalled == false)
	}

	// MARK: - Lazy matchField Resolution

	@Test("matchField (string) resolves via Mirror and validates correctly")
	func matchFieldResolvesViaMirror() {
		let vm = MockRegisterVM_String()
		let validator = FormValidator()

		// Values differ — should fail after lazy resolution
		vm._password.wrappedValue = "secret123"
		vm._confirmPassword.wrappedValue = "wrong"

		#expect(validator.validate(in: vm) == false)
		#expect(vm._confirmPassword.error?.message == "Passwords do not match")
	}

	@Test("matchField (string) passes when values match")
	func matchFieldPassesWhenEqual() {
		let vm = MockRegisterVM_String()
		let validator = FormValidator()

		vm._password.wrappedValue = "secret123"
		vm._confirmPassword.wrappedValue = "secret123"

		#expect(validator.validate(in: vm) == true)
	}

	@Test("matchField (string) sets up dependent tracking — changing password re-validates confirmPassword")
	func matchFieldDependentTracking() {
		let vm = MockRegisterVM_String()
		let validator = FormValidator()

		vm._password.wrappedValue = "secret123"
		vm._confirmPassword.wrappedValue = "secret123"

		// First validate to trigger discovery + resolution
		#expect(validator.validate(in: vm) == true)

		// Now change password — dependent re-validation triggers on confirmPassword
		vm._password.wrappedValue = "changed"
		#expect(vm._confirmPassword.error?.message == "Passwords do not match")
	}

	// MARK: - KeyPath-based matchField

	@Test("matchField (KeyPath) resolves and validates correctly")
	func matchFieldKeyPathResolves() {
		let vm = MockRegisterVM_KeyPath()
		let validator = FormValidator()

		vm._password.wrappedValue = "secret123"
		vm._confirmPassword.wrappedValue = "wrong"

		#expect(validator.validate(in: vm) == false)
		#expect(vm._confirmPassword.error?.message == "Passwords do not match")
	}

	@Test("matchField (KeyPath) passes when values match")
	func matchFieldKeyPathPasses() {
		let vm = MockRegisterVM_KeyPath()
		let validator = FormValidator()

		vm._password.wrappedValue = "secret123"
		vm._confirmPassword.wrappedValue = "secret123"

		#expect(validator.validate(in: vm) == true)
	}

	@Test("matchField (KeyPath) sets up dependent tracking")
	func matchFieldKeyPathDependentTracking() {
		let vm = MockRegisterVM_KeyPath()
		let validator = FormValidator()

		vm._password.wrappedValue = "secret123"
		vm._confirmPassword.wrappedValue = "secret123"

		#expect(validator.validate(in: vm) == true)

		// Change password → dependent re-validation on confirmPassword
		vm._password.wrappedValue = "changed"
		#expect(vm._confirmPassword.error?.message == "Passwords do not match")

		// Fix confirm
		vm._confirmPassword.wrappedValue = "changed"
		#expect(vm._confirmPassword.error == nil)
	}
}

// MARK: - Mock ViewModels

/// String-based matchField mock
@MainActor
private final class MockRegisterVM_String {
	var _password = FormField(wrappedValue: "", rules: [Rules.required()])
	var _confirmPassword = FormField(
		wrappedValue: "",
		rules: [Rules.required(), Rules.matchField("password", message: "Passwords do not match")],
		autoValidate: true
	)
}

/// KeyPath-based matchField mock
@MainActor
private final class MockRegisterVM_KeyPath {
	var _password = FormField(wrappedValue: "", rules: [Rules.required()])
	var _confirmPassword = FormField(
		wrappedValue: "",
		rules: [Rules.required(), Rules.matchField(\MockRegisterVM_KeyPath._password, message: "Passwords do not match")],
		autoValidate: true
	)
}
