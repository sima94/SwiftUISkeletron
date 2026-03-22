//
//  HomeDetailsScreen.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class HomeDetailsScreen: Screen {

	// MARK: - Traits

	override var traits: [XCUIElement] {
		[app.staticTexts["Hello, Details!"]]
	}

	// MARK: - Elements

	var titleLabel: XCUIElement { app.staticTexts["Hello, Details!"] }
	var actionButton: XCUIElement { app.buttons["Action"] }
}
