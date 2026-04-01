//
//  IBANFormatterTests.swift
//  FormValidator
//

import Testing
@testable import FormValidator

@Suite("IBANFormatter")
struct IBANFormatterTests {

	let formatter = IBANFormatter()

	// MARK: - format

	@Test("Formats raw IBAN into groups of 4")
	func formatGroupsOfFour() {
		#expect(formatter.format("DE89370400440532013000") == "DE89 3704 0044 0532 0130 00")
	}

	@Test("Formats short value without spaces")
	func formatShortValue() {
		#expect(formatter.format("DE89") == "DE89")
	}

	@Test("Formats partial IBAN")
	func formatPartialIBAN() {
		#expect(formatter.format("DE893704") == "DE89 3704")
	}

	@Test("Formats empty string")
	func formatEmptyString() {
		#expect(formatter.format("") == "")
	}

	@Test("Formats already-formatted value idempotently")
	func formatIdempotent() {
		let formatted = formatter.format("DE89370400440532013000")
		#expect(formatter.format(formatted) == formatted)
	}

	// MARK: - unformat

	@Test("Strips spaces and uppercases")
	func unformatStripsSpaces() {
		#expect(formatter.unformat("DE89 3704 0044 0532 0130 00") == "DE89370400440532013000")
	}

	@Test("Uppercases lowercase input")
	func unformatUppercases() {
		#expect(formatter.unformat("de89370400440532013000") == "DE89370400440532013000")
	}

	@Test("Truncates to maxLength")
	func unformatTruncates() {
		let long = String(repeating: "A", count: 40)
		#expect(formatter.unformat(long).count == 34)
	}

	@Test("Custom maxLength")
	func customMaxLength() {
		let short = IBANFormatter(maxLength: 22)
		let long = String(repeating: "1", count: 30)
		#expect(short.unformat(long).count == 22)
	}

	// MARK: - Round-trip

	@Test("format then unformat returns original raw value")
	func roundTrip() {
		let raw = "DE89370400440532013000"
		#expect(formatter.unformat(formatter.format(raw)) == raw)
	}

	@Test("unformat then format returns formatted value")
	func reverseRoundTrip() {
		let formatted = "DE89 3704 0044 0532 0130 00"
		#expect(formatter.format(formatter.unformat(formatted)) == formatted)
	}
}
