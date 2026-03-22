//
//  SkeletronApp.swift
//  SwiftUISkeletronUITests
//

import XCTest

final class SkeletronApp: XCUIApplication {

	@discardableResult
	func launch() -> HomeScreen {
		super.launch()
		return HomeScreen(app: self)
	}
}
