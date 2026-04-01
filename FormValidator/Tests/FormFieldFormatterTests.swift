//
//  FormFieldFormatterTests.swift
//  FormValidator
//

import Testing
@testable import FormValidator

@Suite("FormField + TextFormatter Integration")
struct FormFieldFormatterTests {

	// MARK: - displayText

	@Test("displayText returns formatted value when formatter is set")
	@MainActor
	func displayTextFormatted() {
		let field = FormField(wrappedValue: "DE89370400440532013000", formatter: IBANFormatter())
		#expect(field.displayText == "DE89 3704 0044 0532 0130 00")
	}

	@Test("displayText returns raw value when no formatter")
	@MainActor
	func displayTextNoFormatter() {
		let field = FormField(wrappedValue: "DE89370400440532013000")
		#expect(field.displayText == "DE89370400440532013000")
	}

	// MARK: - Validation uses raw value

	@Test("Validation runs against raw (unformatted) value")
	@MainActor
	func validationUsesRawValue() {
		let field = FormField(
			wrappedValue: "",
			rules: [Rules.required()],
			formatter: IBANFormatter()
		)

		// Empty raw value should fail required
		#expect(field.validate() == false)
		#expect(field.error != nil)

		// Set raw value
		field.wrappedValue = "DE89370400440532013000"
		#expect(field.validate() == true)
		#expect(field.error == nil)
	}

	@Test("Regex validation works on raw value, not formatted")
	@MainActor
	func regexOnRawValue() {
		let field = FormField(
			wrappedValue: "DE89370400440532013000",
			rules: [Rules.regex("^[A-Z]{2}\\d+$", message: "Invalid IBAN format")],
			formatter: IBANFormatter()
		)

		// Raw value matches regex (no spaces)
		#expect(field.validate() == true)
	}

	// MARK: - Amount formatter integration

	@Test("Amount formatter: displayText shows grouped value")
	@MainActor
	func amountDisplayText() {
		let field = FormField(
			wrappedValue: "1234567.89",
			formatter: AmountFormatter()
		)
		#expect(field.displayText == "1.234.567,89")
	}

	@Test("Amount formatter: custom validation on raw value")
	@MainActor
	func amountValidation() {
		let field = FormField(
			wrappedValue: "not_a_number",
			rules: [Rules.custom(message: "Invalid amount") { Double($0) != nil }],
			formatter: AmountFormatter()
		)

		#expect(field.validate() == false)

		field.wrappedValue = "1234.56"
		#expect(field.validate() == true)
	}

	// MARK: - Phone formatter integration

	@Test("Phone formatter: displayText shows formatted phone")
	@MainActor
	func phoneDisplayText() {
		let field = FormField(
			wrappedValue: "381631234567",
			formatter: PhoneFormatter(pattern: "+### ## ### ####")
		)
		#expect(field.displayText == "+381 63 123 4567")
	}

	// MARK: - No formatter fallback

	@Test("FormField without formatter works unchanged")
	@MainActor
	func noFormatterFallback() {
		let field = FormField(
			wrappedValue: "hello",
			rules: [Rules.required()]
		)
		#expect(field.displayText == "hello")
		#expect(field.validate() == true)
	}

	// MARK: - autoValidate with formatter

	@Test("autoValidate triggers on wrappedValue change with formatter")
	@MainActor
	func autoValidateWithFormatter() {
		let field = FormField(
			wrappedValue: "",
			rules: [Rules.required()],
			autoValidate: true,
			formatter: IBANFormatter()
		)

		// Set value — autoValidate should clear the error
		field.wrappedValue = "DE89"
		#expect(field.error == nil)
	}

	// MARK: - _formattedText initialization

	@Test("_formattedText is initialized from wrappedValue on init")
	@MainActor
	func formattedTextInit() {
		let field = FormField(wrappedValue: "DE89370400440532013000", formatter: IBANFormatter())
		#expect(field._formattedText == "DE89 3704 0044 0532 0130 00")
	}

	@Test("_formattedText is empty when no formatter")
	@MainActor
	func formattedTextNoFormatter() {
		let field = FormField(wrappedValue: "hello")
		#expect(field._formattedText == "")
	}

	// MARK: - _formattedText sync on wrappedValue change

	@Test("_formattedText syncs when wrappedValue changes programmatically")
	@MainActor
	func formattedTextSyncsOnWrappedValueChange() {
		let field = FormField(wrappedValue: "", formatter: IBANFormatter())
		#expect(field._formattedText == "")

		field.wrappedValue = "DE89370400440532013000"
		#expect(field._formattedText == "DE89 3704 0044 0532 0130 00")
	}

	@Test("_formattedText syncs with AmountFormatter on wrappedValue change")
	@MainActor
	func formattedTextSyncsAmount() {
		let field = FormField(wrappedValue: "", formatter: AmountFormatter())
		field.wrappedValue = "1234567.89"
		#expect(field._formattedText == "1.234.567,89")
	}

	// MARK: - textBinding

	@Test("textBinding.get returns _formattedText when formatter is present")
	@MainActor
	func textBindingGetFormatted() {
		let field = FormField(wrappedValue: "DE89370400440532013000", formatter: IBANFormatter())
		#expect(field.textBinding.wrappedValue == "DE89 3704 0044 0532 0130 00")
	}

	@Test("textBinding.get returns wrappedValue when no formatter")
	@MainActor
	func textBindingGetNoFormatter() {
		let field = FormField(wrappedValue: "hello")
		#expect(field.textBinding.wrappedValue == "hello")
	}

	@Test("textBinding.set stores raw in wrappedValue and formatted in _formattedText")
	@MainActor
	func textBindingSetStoresBoth() {
		let field = FormField(wrappedValue: "", formatter: IBANFormatter())

		// Simulate typing "DE89370400440532013000"
		field.textBinding.wrappedValue = "DE89370400440532013000"

		// wrappedValue should be raw (no spaces)
		#expect(field.wrappedValue == "DE89370400440532013000")
		// _formattedText should be formatted
		#expect(field._formattedText == "DE89 3704 0044 0532 0130 00")
		// textBinding.get should return formatted
		#expect(field.textBinding.wrappedValue == "DE89 3704 0044 0532 0130 00")
	}

	@Test("textBinding.set handles already-formatted input (idempotent)")
	@MainActor
	func textBindingSetIdempotent() {
		let field = FormField(wrappedValue: "", formatter: IBANFormatter())

		// User types formatted text (e.g., paste)
		field.textBinding.wrappedValue = "DE89 3704 0044"

		// unformat → "DE893704 0044" → raw = "DE8937040044"... wait, unformat strips spaces
		#expect(field.wrappedValue == "DE8937040044")
		#expect(field._formattedText == "DE89 3704 0044")
	}

	@Test("textBinding.set without formatter passes through directly")
	@MainActor
	func textBindingSetNoFormatter() {
		let field = FormField(wrappedValue: "")

		field.textBinding.wrappedValue = "hello"
		#expect(field.wrappedValue == "hello")
	}

	@Test("textBinding.set triggers validation when autoValidate is on")
	@MainActor
	func textBindingSetTriggersValidation() {
		let field = FormField(
			wrappedValue: "valid",
			rules: [Rules.required()],
			autoValidate: true,
			formatter: IBANFormatter()
		)

		// Set empty via textBinding → should trigger validation error
		field.textBinding.wrappedValue = ""
		#expect(field.error != nil)
	}

	@Test("textBinding with PhoneFormatter formats live input")
	@MainActor
	func textBindingPhoneLiveFormat() {
		let field = FormField(
			wrappedValue: "",
			formatter: PhoneFormatter(pattern: "+### ## ### ####")
		)

		// Simulate typing digits
		field.textBinding.wrappedValue = "38163"

		#expect(field.wrappedValue == "38163")
		#expect(field._formattedText == "+381 63")
		#expect(field.textBinding.wrappedValue == "+381 63")
	}

	@Test("textBinding with AmountFormatter formats live input")
	@MainActor
	func textBindingAmountLiveFormat() {
		let field = FormField(
			wrappedValue: "",
			formatter: AmountFormatter()
		)

		field.textBinding.wrappedValue = "1234567"

		#expect(field.wrappedValue == "1234567")
		#expect(field._formattedText == "1.234.567")
		#expect(field.textBinding.wrappedValue == "1.234.567")
	}
}
