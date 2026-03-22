//
//  TabNavigationTests.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class TabNavigationTests: XCTestCase {

	let app = SkeletronApp()

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testTabBar_showsHomeAndProfileTabs() throws {
		app.launch()
			.verifyTabBarVisible()
	}

	@MainActor
	func testTabBar_switchToProfile() throws {
		app.launch()
			.tapProfileTab()
	}
}
