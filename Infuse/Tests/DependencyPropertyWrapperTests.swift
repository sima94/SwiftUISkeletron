//
//  DependencyPropertyWrapperTests.swift
//  InfuseTests
//

import Testing
@testable import Infuse

@Suite("Dependency property wrapper", .serialized)
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

	@Test("property wrapper lazily resolves on first access")
	func lazyResolution() {
		// Override AFTER creating the wrapper — should pick up the override
		@Dependency(StringKey.self) var value
		DependencyValues.shared.override(StringKey.self, with: "lazy-injected")
		#expect(value == "lazy-injected")
		DependencyValues.shared.removeOverride(StringKey.self)
	}

	@Test("property wrapper caches value after first access")
	func cachesAfterFirstAccess() {
		DependencyValues.shared.override(StringKey.self, with: "first")
		@Dependency(StringKey.self) var value

		// First access caches "first"
		#expect(value == "first")

		// Change override — cached value should not change
		DependencyValues.shared.override(StringKey.self, with: "second")
		#expect(value == "first")

		DependencyValues.shared.removeOverride(StringKey.self)
	}
}
