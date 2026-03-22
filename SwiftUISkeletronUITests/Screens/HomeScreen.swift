//
//  HomeScreen.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class HomeScreen: Screen {

	// MARK: - Traits

	override var traits: [XCUIElement] {
		[app.tabBars.firstMatch, app.collectionViews.firstMatch]
	}

	// MARK: - Elements

	var homeTab: XCUIElement { app.tabBars.buttons["Home"] }
	var profileTab: XCUIElement { app.tabBars.buttons["Profile"] }
	var firstItem: XCUIElement { app.collectionViews.firstMatch.buttons.firstMatch }

	// MARK: - Actions

	@discardableResult
	func tapFirstItem() -> HomeDetailsScreen {
		XCTAssertTrue(firstItem.waitForExistence(timeout: 3), "List item did not appear")
		firstItem.tap()
		return HomeDetailsScreen(app: app)
	}

	@discardableResult
	func tapProfileTab() -> ProfileScreen {
		profileTab.tap()
		return ProfileScreen(app: app)
	}

	// MARK: - Verifications

	@discardableResult
	func verifyHasItems() -> Self {
		XCTAssertTrue(firstItem.waitForExistence(timeout: 3), "List should have at least one item")
		return self
	}

	@discardableResult
	func verifyTabBarVisible() -> Self {
		XCTAssertTrue(homeTab.exists, "Home tab should exist")
		XCTAssertTrue(profileTab.exists, "Profile tab should exist")
		return self
	}
}
