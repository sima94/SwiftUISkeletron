//
//  DependencyContextTests.swift
//  InfuseTests
//

import Testing
@testable import Infuse

@Suite("DependencyContext", .serialized)
struct DependencyContextTests {

	@Test("current returns a valid context")
	func currentReturnsValidContext() {
		let context = DependencyContext.current
		// In Xcode test runner → .test, in SPM swift test → .live (no XCTest linked)
		#expect(context == .test || context == .live)
	}

	@Test("live and test are distinct cases")
	func casesAreDistinct() {
		#expect(DependencyContext.live != .test)
	}

	@Test("test context resolves testValue")
	func testContextResolvesTestValue() {
		DependencyValues.shared.reset()
		// When running in Xcode (.test context), StringKey resolves to "test"
		// When running in SPM (.live context), StringKey resolves to "live"
		let value = DependencyValues.shared.resolve(StringKey.self)
		let context = DependencyContext.current
		let expected = context == .test ? "test" : "live"
		#expect(value == expected)
	}
}
