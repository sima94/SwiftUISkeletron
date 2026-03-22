//
//  DependencyPropertyWrapperTests.swift
//  InfuseTests
//

import Testing
@testable import Infuse

@Suite("Dependency property wrapper")
struct DependencyPropertyWrapperTests {

	init() {
		DependencyValues.shared.reset()
	}

	@Test("property wrapper resolves value")
	func propertyWrapperResolves() {
		DependencyValues.shared.override(StringKey.self, with: "injected")
		@Dependency(StringKey.self) var value
		#expect(value == "injected")
		DependencyValues.shared.removeOverride(StringKey.self)
	}
}
