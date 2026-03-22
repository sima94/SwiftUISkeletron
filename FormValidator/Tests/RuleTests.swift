//
//  RuleTests.swift
//  FormValidator
//

import Testing
@testable import FormValidator

// MARK: - RequiredRule Tests

@Suite("RequiredRule")
struct RequiredRuleTests {

	@Test("Empty string fails")
	func emptyStringFails() {
		let rule = RequiredRule<String>()
		let result = rule.validate("")
		switch result {
		case .success:
			Issue.record("Expected failure for empty string")
		case .failure(let error):
			#expect(error.message == "This field is required")
		}
	}

	@Test("Whitespace-only string fails")
	func whitespaceOnlyFails() {
		let rule = RequiredRule<String>()
		let result = rule.validate("   \n\t  ")
		switch result {
		case .success:
			Issue.record("Expected failure")
		case .failure:
			break
		}
	}

	@Test("Non-empty string succeeds")
	func nonEmptyStringSucceeds() {
		let rule = RequiredRule<String>()
		let result = rule.validate("hello")
		switch result {
		case .success: break
		case .failure: Issue.record("Expected success")
		}
	}

	@Test("Optional nil fails")
	func optionalNilFails() {
		let rule = RequiredRule<String?>()
		let result = rule.validate(nil)
		switch result {
		case .success: Issue.record("Expected failure")
		case .failure: break
		}
	}

	@Test("Optional with value succeeds")
	func optionalWithValueSucceeds() {
		let rule = RequiredRule<String?>()
		let result = rule.validate("hello")
		switch result {
		case .success: break
		case .failure: Issue.record("Expected success")
		}
	}
}

// MARK: - StringLengthRule Tests

@Suite("StringLengthRule")
struct StringLengthRuleTests {

	@Test("Below minimum fails")
	func belowMinimumFails() {
		let rule = StringLengthRule(min: 5, message: "Too short")
		switch rule.validate("abc") {
		case .success: Issue.record("Expected failure")
		case .failure(let error): #expect(error.message == "Too short")
		}
	}

	@Test("At minimum succeeds")
	func atMinimumSucceeds() {
		let rule = StringLengthRule(min: 3, message: "Too short")
		switch rule.validate("abc") {
		case .success: break
		case .failure: Issue.record("Expected success")
		}
	}

	@Test("Above maximum fails")
	func aboveMaximumFails() {
		let rule = StringLengthRule(max: 5, message: "Too long")
		switch rule.validate("abcdefgh") {
		case .success: Issue.record("Expected failure")
		case .failure(let error): #expect(error.message == "Too long")
		}
	}

	@Test("Password factory creates min 8 rule")
	func passwordFactory() {
		let rule = StringLengthRule.password()
		switch rule.validate("12345") {
		case .success: Issue.record("Expected failure")
		case .failure: break
		}
		switch rule.validate("12345678") {
		case .success: break
		case .failure: Issue.record("Expected success")
		}
	}
}

// MARK: - RegexRule Tests

@Suite("RegexRule")
struct RegexRuleTests {

	@Test("Matching pattern succeeds")
	func matchingPatternSucceeds() {
		let rule = RegexRule("^[0-9]+$", message: "Numbers only")
		switch rule.validate("12345") {
		case .success: break
		case .failure: Issue.record("Expected success")
		}
	}

	@Test("Non-matching pattern fails")
	func nonMatchingPatternFails() {
		let rule = RegexRule("^[0-9]+$", message: "Numbers only")
		switch rule.validate("abc123") {
		case .success: Issue.record("Expected failure")
		case .failure(let error): #expect(error.message == "Numbers only")
		}
	}
}

// MARK: - BoolRule Tests

@Suite("BoolRule")
struct BoolRuleTests {

	@Test("Expected true succeeds")
	func expectedTrueSucceeds() {
		let rule = BoolRule(expected: true)
		switch rule.validate(true) {
		case .success: break
		case .failure: Issue.record("Expected success")
		}
	}

	@Test("Expected true fails for false")
	func expectedTrueFails() {
		let rule = BoolRule(expected: true)
		switch rule.validate(false) {
		case .success: Issue.record("Expected failure")
		case .failure(let error): #expect(error.message == "This field must be accepted")
		}
	}
}

// MARK: - CommonRules Tests

@Suite("CommonRules")
struct CommonRulesTests {

	@Test("Rules.email validates correct email")
	func emailValid() {
		switch Rules.email().validate("user@example.com") {
		case .success: break
		case .failure: Issue.record("Expected success")
		}
	}

	@Test("Rules.email rejects invalid email")
	func emailInvalid() {
		switch Rules.email().validate("not-an-email") {
		case .success: Issue.record("Expected failure")
		case .failure: break
		}
	}

	@Test("Rules.email accepts plus sign")
	func emailPlusSign() {
		switch Rules.email().validate("user+tag@example.com") {
		case .success: break
		case .failure: Issue.record("Expected success")
		}
	}
}
