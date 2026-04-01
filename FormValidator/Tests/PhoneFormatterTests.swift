//
//  PhoneFormatterTests.swift
//  FormValidator
//

import Testing
@testable import FormValidator

@Suite("PhoneFormatter")
struct PhoneFormatterTests {

	let formatter = PhoneFormatter(pattern: "+### ## ### ####")

	// MARK: - format

	@Test("Formats full phone number")
	func formatFullNumber() {
		#expect(formatter.format("381631234567") == "+381 63 123 4567")
	}

	@Test("Formats partial number")
	func formatPartialNumber() {
		#expect(formatter.format("38163") == "+381 63")
	}

	@Test("Formats empty string")
	func formatEmpty() {
		#expect(formatter.format("") == "")
	}

	@Test("Formats single digit")
	func formatSingleDigit() {
		#expect(formatter.format("3") == "+3")
	}

	@Test("Truncates excess digits to pattern capacity")
	func formatTruncatesExcess() {
		#expect(formatter.format("3816312345679999") == "+381 63 123 4567")
	}

	// MARK: - unformat

	@Test("Strips all non-digit characters")
	func unformatStripsNonDigits() {
		#expect(formatter.unformat("+381 63 123 4567") == "381631234567")
	}

	@Test("Strips parentheses and dashes")
	func unformatStripsMixedChars() {
		let us = PhoneFormatter(pattern: "+# (###) ###-####")
		#expect(us.unformat("+1 (234) 567-8901") == "12345678901")
	}

	@Test("Truncates excess digits on unformat")
	func unformatTruncates() {
		#expect(formatter.unformat("12345678901234567890").count == 12)
	}

	// MARK: - Different patterns

	@Test("US phone pattern")
	func usPattern() {
		let us = PhoneFormatter(pattern: "+# (###) ###-####")
		#expect(us.format("12345678901") == "+1 (234) 567-8901")
		#expect(us.unformat("+1 (234) 567-8901") == "12345678901")
	}

	@Test("Simple pattern without prefix characters")
	func simplePattern() {
		let simple = PhoneFormatter(pattern: "### ### ####")
		#expect(simple.format("0631234567") == "063 123 4567")
	}

	// MARK: - Round-trip

	@Test("format then unformat returns original raw value")
	func roundTrip() {
		let raw = "381631234567"
		#expect(formatter.unformat(formatter.format(raw)) == raw)
	}

	@Test("unformat then format returns formatted value")
	func reverseRoundTrip() {
		let formatted = "+381 63 123 4567"
		#expect(formatter.format(formatter.unformat(formatted)) == formatted)
	}
}
