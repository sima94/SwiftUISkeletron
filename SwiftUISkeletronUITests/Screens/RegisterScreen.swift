//
//  RegisterScreen.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class RegisterScreen: Screen {

	// MARK: - Traits

	override var traits: [XCUIElement] {
		[app.staticTexts["Register"], app.textFields["Username"]]
	}

	// MARK: - Elements

	var usernameField: XCUIElement { app.textFields["Username"] }
	var firstNameField: XCUIElement { app.textFields["First Name"] }
	var lastNameField: XCUIElement { app.textFields["Last Name"] }
	var emailField: XCUIElement { app.textFields["Email"] }
	var passwordField: XCUIElement { app.secureTextFields["Password"] }
	var confirmPasswordField: XCUIElement { app.secureTextFields["Confirm Password"] }
	var registerButton: XCUIElement { app.buttons["Register"] }

	// MARK: - Error Elements

	var requiredFieldErrors: XCUIElementQuery { app.staticTexts.matching(NSPredicate(format: "label == %@", "This field is required")) }
	var emailError: XCUIElement { app.staticTexts["Please enter a valid email address"] }
	var passwordError: XCUIElement { app.staticTexts["Password must be at least 8 characters"] }
	var confirmPasswordError: XCUIElement { app.staticTexts["Passwords do not match"] }

	// MARK: - Actions

	@discardableResult
	func enterUsername(_ text: String) -> Self {
		usernameField.tap()
		usernameField.typeText(text)
		return self
	}

	@discardableResult
	func enterFirstName(_ text: String) -> Self {
		firstNameField.tap()
		firstNameField.typeText(text)
		return self
	}

	@discardableResult
	func enterLastName(_ text: String) -> Self {
		lastNameField.tap()
		lastNameField.typeText(text)
		return self
	}

	@discardableResult
	func enterEmail(_ text: String) -> Self {
		emailField.tap()
		emailField.typeText(text)
		return self
	}

	@discardableResult
	func enterPassword(_ text: String) -> Self {
		passwordField.tap()
		passwordField.typeText(text)
		return self
	}

	@discardableResult
	func enterConfirmPassword(_ text: String) -> Self {
		confirmPasswordField.tap()
		confirmPasswordField.typeText(text)
		return self
	}

	@discardableResult
	func tapRegisterButton() -> Self {
		registerButton.tap()
		return self
	}

	// MARK: - Verifications

	@discardableResult
	func verifyRequiredFieldErrors(count: Int) -> Self {
		let firstError = requiredFieldErrors.firstMatch
		XCTAssertTrue(firstError.waitForExistence(timeout: 3), "Required field errors should appear")
		XCTAssertEqual(requiredFieldErrors.count, count, "Expected \(count) 'required' errors")
		return self
	}

	@discardableResult
	func verifyPasswordMatchError() -> Self {
		XCTAssertTrue(confirmPasswordError.waitForExistence(timeout: 3), "Password match error should appear")
		return self
	}

	@discardableResult
	func verifyNoPasswordMatchError() -> Self {
		XCTAssertFalse(confirmPasswordError.exists, "Password match error should not appear")
		return self
	}
}
