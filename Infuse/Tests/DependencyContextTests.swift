//
//  DependencyContextTests.swift
//  InfuseTests
//

import Testing
@testable import Infuse

@Suite("DependencyContext")
struct DependencyContextTests {

	@Test("current returns .test inside test target")
	func currentReturnsTestInTestTarget() {
		#expect(DependencyContext.current == .test)
	}

	@Test("all three cases are distinct")
	func casesAreDistinct() {
		#expect(DependencyContext.live != .test)
		#expect(DependencyContext.live != .preview)
		#expect(DependencyContext.test != .preview)
	}
}
