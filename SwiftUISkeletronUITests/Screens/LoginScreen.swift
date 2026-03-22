//
//  LoginScreen.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class LoginScreen: Screen {

	// MARK: - Traits

	override var traits: [XCUIElement] {
		[app.staticTexts["Login"], app.textFields["Username"]]
	}

	override var timeout: TimeInterval { 15 }

	// MARK: - Elements

	var usernameField: XCUIElement { app.textFields["Username"] }
	var passwordField: XCUIElement { app.textFields["Password"] }
	var loginButton: XCUIElement { app.buttons["Login"] }
	var registerButton: XCUIElement { app.buttons["Go to Register"] }

	// MARK: - Error Elements

	var usernameError: XCUIElement { app.staticTexts["This field is required"] }
	var passwordError: XCUIElement { app.staticTexts["Password must be at least 8 characters"] }

	// MARK: - Actions

	@discardableResult
	func enterUsername(_ text: String) -> Self {
		usernameField.tap()
		usernameField.typeText(text)
		return self
	}

	@discardableResult
	func enterPassword(_ text: String) -> Self {
		passwordField.tap()
		passwordField.typeText(text)
		return self
	}

	@discardableResult
	func tapLoginButton() -> Self {
		loginButton.tap()
		return self
	}

	@discardableResult
	func tapRegisterButton() -> RegisterScreen {
		registerButton.tap()
		return RegisterScreen(app: app)
	}

	// MARK: - Verifications

	@discardableResult
	func verifyValidationErrors() -> Self {
		XCTAssertTrue(usernameError.waitForExistence(timeout: 3), "Username required error should appear")
		return self
	}

	@discardableResult
	func verifyNoValidationErrors() -> Self {
		XCTAssertFalse(usernameError.exists, "Username error should not appear")
		return self
	}
}
