//
//  Screen.swift
//  SwiftUISkeletronUITests
//

import XCTest

/// Base class for the Screen Object pattern.
/// Every screen validates its presence on init by waiting for all `traits` elements.
class Screen {

	let app: XCUIApplication

	/// Elements that must all exist for this screen to be considered visible.
	/// Override in every subclass. All traits are validated on init.
	var traits: [XCUIElement] {
		fatalError("Subclass must override `traits`")
	}

	/// Maximum time to wait for the screen to appear (seconds).
	var timeout: TimeInterval { 5 }

	@discardableResult
	required init(app: XCUIApplication, file: StaticString = #file, line: UInt = #line) {
		self.app = app
		for trait in traits {
			XCTAssertTrue(
				trait.waitForExistence(timeout: timeout),
				"\(type(of: self)) — trait not found: \(trait)",
				file: file,
				line: line
			)
		}
	}
}
