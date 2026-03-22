//
//  HomeListTests.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class HomeListTests: XCTestCase {

	let app = SkeletronApp()

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	@MainActor
	func testHomeList_displaysItems() throws {
		app.launch()
			.verifyHasItems()
	}

	@MainActor
	func testHomeList_tapItemNavigatesToDetails() throws {
		app.launch()
			.tapFirstItem()
	}
}
