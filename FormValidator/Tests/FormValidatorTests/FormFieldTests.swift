//
//  FormFieldTests.swift
//  FormValidator
//

import Testing
@testable import FormValidator

@Suite("FormField")
@MainActor
struct FormFieldTests {

	@Test("Validate with passing rules returns true")
	func validatePassingRules() {
		let field = FormField(wrappedValue: "hello", rules: [Rules.required()])
		#expect(field.validate() == true)
		#expect(field.error == nil)
	}

	@Test("Validate with failing rule sets error")
	func validateFailingRule() {
		let field = FormField(wrappedValue: "", rules: [Rules.required()])
		#expect(field.validate() == false)
		#expect(field.error?.message == "This field is required")
	}

	@Test("First error mode stops at first failure")
	func firstErrorMode() {
		let field = FormField(
			wrappedValue: "",
			rules: [Rules.required(message: "Required"), Rules.minLength(5, message: "Too short")],
			errorDisplayMode: .first
		)
		field.validate()
		#expect(field.errors.count == 1)
		#expect(field.error?.message == "Required")
	}

	@Test("All errors mode collects all failures")
	func allErrorsMode() {
		let field = FormField(
			wrappedValue: "ab",
			rules: [Rules.minLength(5, message: "Too short"), Rules.regex("^[0-9]+$", message: "Numbers only")],
			errorDisplayMode: .all
		)
		field.validate()
		#expect(field.errors.count == 2)
	}

	@Test("Auto-validate triggers on value change")
	func autoValidateTriggers() {
		let field = FormField(wrappedValue: "hello", rules: [Rules.required()], autoValidate: true)
		field.wrappedValue = ""
		#expect(field.error != nil)
		field.wrappedValue = "world"
		#expect(field.error == nil)
	}

	@Test("Disabled field always validates as true")
	func disabledFieldAlwaysValid() {
		let field = FormField(wrappedValue: "", rules: [Rules.required()])
		field.isEnabled = false
		#expect(field.validate() == true)
		#expect(field.error == nil)
	}

	@Test("Disabling field clears existing errors")
	func disablingClearsErrors() {
		let field = FormField(wrappedValue: "", rules: [Rules.required()])
		field.validate()
		#expect(field.error != nil)
		field.isEnabled = false
		#expect(field.error == nil)
	}

	@Test("Match field sets error when values differ")
	func matchFieldDirect() {
		let password = FormField(wrappedValue: "secret123", rules: [Rules.required()])
		let confirm = FormField(wrappedValue: "different", rules: [Rules.required()])
		confirm.match(password, message: "Passwords do not match")

		#expect(confirm.validate() == false)
		#expect(confirm.error?.message == "Passwords do not match")
	}

	@Test("Match field passes when values are equal")
	func matchFieldPasses() {
		let password = FormField(wrappedValue: "secret123", rules: [Rules.required()])
		let confirm = FormField(wrappedValue: "secret123", rules: [Rules.required()])
		confirm.match(password, message: "Passwords do not match")

		#expect(confirm.validate() == true)
	}

	@Test("Changing matched field re-validates dependent")
	func matchDependentRevalidation() {
		let password = FormField(wrappedValue: "secret123", rules: [Rules.required()])
		let confirm = FormField(wrappedValue: "secret123", rules: [Rules.required()], autoValidate: true)
		confirm.match(password, message: "Passwords do not match")

		// Initially matching
		#expect(confirm.validate() == true)

		// Changing password triggers confirm re-validation → now mismatched
		password.wrappedValue = "changed"
		#expect(confirm.error?.message == "Passwords do not match")

		// Fix confirm to match
		confirm.wrappedValue = "changed"
		#expect(confirm.error == nil)
	}
}
