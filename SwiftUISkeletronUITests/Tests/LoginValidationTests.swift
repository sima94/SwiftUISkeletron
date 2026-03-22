//
//  LoginValidationTests.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class LoginValidationTests: XCTestCase {

	let app = SkeletronApp()

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testLogin_showsValidationErrors_whenFieldsEmpty() throws {
		app.launch()
			.tapProfileTab()
			.tapLogin()
			.tapLoginButton()
			.verifyValidationErrors()
	}

	@MainActor
	func testLogin_showsPasswordError_whenPasswordTooShort() throws {
		let loginScreen = app.launch()
			.tapProfileTab()
			.tapLogin()
			.enterUsername("testuser")
			.enterPassword("short")
			.tapLoginButton()

		XCTAssertTrue(
			loginScreen.passwordError.waitForExistence(timeout: 3),
			"Password length error should appear"
		)
		loginScreen.verifyNoValidationErrors()
	}
}
