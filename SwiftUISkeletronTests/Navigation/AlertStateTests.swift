//
//  AlertStateTests.swift
//  SwiftUISkeletronTests
//

import Testing
import SwiftUI
@testable import SwiftUISkeletron

// MARK: - AlertAction Tests

@Suite("AlertAction")
struct AlertActionTests {

	@Test("None actions are equal")
	func noneEquality() {
		#expect(AlertAction.none == AlertAction.none)
	}

	@Test("Custom actions with same string are equal")
	func customEqualitySame() {
		#expect(AlertAction.custom("delete") == AlertAction.custom("delete"))
	}

	@Test("Custom actions with different strings are not equal")
	func customEqualityDifferent() {
		#expect(AlertAction.custom("delete") != AlertAction.custom("save"))
	}

	@Test("None and custom are not equal")
	func noneVsCustom() {
		#expect(AlertAction.none != AlertAction.custom("delete"))
	}
}

// MARK: - ButtonState Factory Tests

@Suite("AlertState.ButtonState")
struct ButtonStateTests {

	@Test("Default button has nil role and given action")
	func defaultButton() {
		let button = AlertState.ButtonState.default("OK")
		#expect(button.title == "OK")
		#expect(button.role == nil)
		#expect(button.action == .none)
	}

	@Test("Default button with custom action")
	func defaultButtonWithAction() {
		let button = AlertState.ButtonState.default("Save", action: .custom("save"))
		#expect(button.title == "Save")
		#expect(button.action == .custom("save"))
	}

	@Test("Cancel button has cancel role")
	func cancelButton() {
		let button = AlertState.ButtonState.cancel()
		#expect(button.title == "Cancel")
		#expect(button.role == .cancel)
		#expect(button.action == .none)
	}

	@Test("Cancel button with custom title")
	func cancelButtonCustomTitle() {
		let button = AlertState.ButtonState.cancel("Dismiss")
		#expect(button.title == "Dismiss")
		#expect(button.role == .cancel)
	}

	@Test("Destructive button has destructive role")
	func destructiveButton() {
		let button = AlertState.ButtonState.destructive("Delete")
		#expect(button.title == "Delete")
		#expect(button.role == .destructive)
		#expect(button.action == .none)
	}

	@Test("Destructive button with custom action")
	func destructiveButtonWithAction() {
		let button = AlertState.ButtonState.destructive("Remove", action: .custom("remove"))
		#expect(button.title == "Remove")
		#expect(button.action == .custom("remove"))
	}

	@Test("Equality compares title and action, ignores role")
	func equalityIgnoresRole() {
		let a = AlertState.ButtonState.default("OK")
		let b = AlertState.ButtonState.cancel("OK")
		#expect(a == b)
	}

	@Test("Inequality on different titles")
	func inequalityOnTitle() {
		let a = AlertState.ButtonState.default("OK")
		let b = AlertState.ButtonState.default("Cancel")
		#expect(a != b)
	}

	@Test("Inequality on different actions")
	func inequalityOnAction() {
		let a = AlertState.ButtonState.default("OK", action: .none)
		let b = AlertState.ButtonState.default("OK", action: .custom("x"))
		#expect(a != b)
	}
}

// MARK: - AlertState Tests

@Suite("AlertState")
struct AlertStateTests {

	@Test("Init with title and primary button")
	func basicInit() {
		let alert = AlertState(
			title: "Error",
			primaryButton: .default("OK")
		)
		#expect(alert.title == "Error")
		#expect(alert.message == nil)
		#expect(alert.primaryButton.title == "OK")
		#expect(alert.secondaryButton == nil)
	}

	@Test("Init with all fields")
	func fullInit() {
		let alert = AlertState(
			title: "Delete?",
			message: "This cannot be undone.",
			primaryButton: .destructive("Delete", action: .custom("delete")),
			secondaryButton: .cancel()
		)
		#expect(alert.title == "Delete?")
		#expect(alert.message == "This cannot be undone.")
		#expect(alert.primaryButton.role == .destructive)
		#expect(alert.secondaryButton?.role == .cancel)
	}

	@Test("Equal alerts are equal")
	func equality() {
		let a = AlertState(title: "A", primaryButton: .default("OK"))
		let b = AlertState(title: "A", primaryButton: .default("OK"))
		#expect(a == b)
	}

	@Test("Different titles are not equal")
	func inequalityTitle() {
		let a = AlertState(title: "A", primaryButton: .default("OK"))
		let b = AlertState(title: "B", primaryButton: .default("OK"))
		#expect(a != b)
	}

	@Test("Different messages are not equal")
	func inequalityMessage() {
		let a = AlertState(title: "A", message: "X", primaryButton: .default("OK"))
		let b = AlertState(title: "A", message: "Y", primaryButton: .default("OK"))
		#expect(a != b)
	}

	@Test("With vs without secondary button are not equal")
	func inequalitySecondary() {
		let a = AlertState(title: "A", primaryButton: .default("OK"))
		let b = AlertState(title: "A", primaryButton: .default("OK"), secondaryButton: .cancel())
		#expect(a != b)
	}
}
