//
//  RegisterValidationTests.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class RegisterValidationTests: XCTestCase {

	let app = SkeletronApp()

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testRegister_showsValidationErrors_whenFieldsEmpty() throws {
		app.launch()
			.tapProfileTab()
			.tapLogin()
			.tapRegisterButton()
			.tapRegisterButton()
			.verifyRequiredFieldErrors(count: 4)
	}

	@MainActor
	func testRegister_showsPasswordMatchError_whenPasswordsDiffer() throws {
		let registerScreen = app.launch()
			.tapProfileTab()
			.tapLogin()
			.tapRegisterButton()
			.enterUsername("testuser")
			.enterFirstName("John")
			.enterLastName("Doe")
			.enterEmail("john@example.com")
			.enterPassword("password123")
			.enterConfirmPassword("different123")
			.tapRegisterButton()

		registerScreen.verifyPasswordMatchError()
	}
}
