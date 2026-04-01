//
//  AmountFormatterTests.swift
//  FormValidator
//

import Foundation
import Testing
@testable import FormValidator

@Suite("AmountFormatter")
struct AmountFormatterTests {

	let formatter = AmountFormatter(groupingSeparator: ".", decimalSeparator: ",", maxDecimalPlaces: 2)

	// MARK: - format

	@Test("Formats integer with thousands grouping")
	func formatInteger() {
		#expect(formatter.format("1234567") == "1.234.567")
	}

	@Test("Formats value with decimals")
	func formatWithDecimals() {
		#expect(formatter.format("1234.56") == "1.234,56")
	}

	@Test("Formats small number without grouping")
	func formatSmallNumber() {
		#expect(formatter.format("123") == "123")
	}

	@Test("Formats zero")
	func formatZero() {
		#expect(formatter.format("0") == "0")
	}

	@Test("Formats empty string")
	func formatEmpty() {
		#expect(formatter.format("") == "")
	}

	@Test("Formats value with only decimals")
	func formatDecimalOnly() {
		#expect(formatter.format("0.99") == "0,99")
	}

	// MARK: - unformat

	@Test("Strips grouping separator and normalizes decimal")
	func unformatBasic() {
		#expect(formatter.unformat("1.234,56") == "1234.56")
	}

	@Test("Strips leading zeros")
	func unformatLeadingZeros() {
		#expect(formatter.unformat("007") == "7")
	}

	@Test("Keeps 0 for zero value")
	func unformatZero() {
		#expect(formatter.unformat("0") == "0")
	}

	@Test("Limits decimal places")
	func unformatLimitsDecimals() {
		#expect(formatter.unformat("1234,5678") == "1234.56")
	}

	@Test("Handles only digits")
	func unformatOnlyDigits() {
		#expect(formatter.unformat("abc123def") == "123")
	}

	@Test("Handles decimal without integer part")
	func unformatDecimalWithoutInteger() {
		#expect(formatter.unformat(",99") == "0.99")
	}

	// MARK: - Different separators

	@Test("US-style formatting (comma grouping, dot decimal)")
	func usStyleFormatting() {
		let us = AmountFormatter(groupingSeparator: ",", decimalSeparator: ".", maxDecimalPlaces: 2)
		#expect(us.format("1234.56") == "1,234.56")
		#expect(us.unformat("1,234.56") == "1234.56")
	}

	// MARK: - Round-trip

	@Test("format then unformat returns original raw value")
	func roundTrip() {
		let raw = "1234567.89"
		#expect(formatter.unformat(formatter.format(raw)) == raw)
	}

	// MARK: - Max decimal places

	@Test("Custom max decimal places")
	func customMaxDecimals() {
		let f = AmountFormatter(groupingSeparator: ".", decimalSeparator: ",", maxDecimalPlaces: 4)
		#expect(f.unformat("1234,56789") == "1234.5678")
		#expect(f.format("1234.5678") == "1.234,5678")
	}

	// MARK: - Locale-based init

	@Test("Locale-based init uses locale separators")
	func localeBasedInit() {
		let deLocale = Locale(identifier: "de_DE")
		let de = AmountFormatter(locale: deLocale, maxDecimalPlaces: 2)
		#expect(de.groupingSeparator == ".")
		#expect(de.decimalSeparator == ",")
		#expect(de.format("1234.56") == "1.234,56")

		let usLocale = Locale(identifier: "en_US")
		let us = AmountFormatter(locale: usLocale, maxDecimalPlaces: 2)
		#expect(us.groupingSeparator == ",")
		#expect(us.decimalSeparator == ".")
		#expect(us.format("1234.56") == "1,234.56")
	}
}
