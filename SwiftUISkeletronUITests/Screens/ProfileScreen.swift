//
//  ProfileScreen.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class ProfileScreen: Screen {

	// MARK: - Traits

	override var traits: [XCUIElement] {
		[app.staticTexts["Profile"]]
	}

	// MARK: - Elements

	var loginButton: XCUIElement { app.buttons["Login"] }
	var registerButton: XCUIElement { app.buttons["Register"] }
	var logoutButton: XCUIElement { app.buttons["Logout"] }

	// MARK: - Actions

	@discardableResult
	func tapLogin() -> LoginScreen {
		XCTAssertTrue(loginButton.waitForExistence(timeout: 3), "Login button did not appear")
		loginButton.tap()
		return LoginScreen(app: app)
	}

	// MARK: - Verifications

	@discardableResult
	func verifyLoggedOut() -> Self {
		XCTAssertTrue(loginButton.waitForExistence(timeout: 3), "Login button should appear when logged out")
		return self
	}
}
