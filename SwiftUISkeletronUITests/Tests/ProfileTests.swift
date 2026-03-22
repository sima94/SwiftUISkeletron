//
//  ProfileTests.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class ProfileTests: XCTestCase {

	let app = SkeletronApp()

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testProfile_showsLoginButton_whenLoggedOut() throws {
		app.launch()
			.tapProfileTab()
			.verifyLoggedOut()
	}

	@MainActor
	func testProfile_navigateToLogin() throws {
		app.launch()
			.tapProfileTab()
			.tapLogin()
	}
}
