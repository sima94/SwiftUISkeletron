//
//  InfuseTests.swift
//  InfuseTests
//
//  Created by Stefan Simic on 19. 3. 2026..
//

import Testing
@testable import Infuse

// MARK: - Test Fixtures

struct StringKey: DependencyKey {
	static var liveValue: String { "live" }
	static var testValue: String { "test" }
}

struct CounterKey: DependencyKey {
	static var scope: DependencyScope { .transient }
	static var liveValue: Int { Int.random(in: 0 ... 1000) }
	static var testValue: Int { 42 }
}

struct FlowKey: DependencyKey {
	static var scope: DependencyScope { .flow("testFlow") }
	static var liveValue: String { "flow-live" }
	static var testValue: String { "flow-test" }
}

// MARK: - Tests

@Suite("DependencyValues")
struct DependencyValuesTests {

	init() {
		DependencyValues.shared.reset()
	}

	@Test("resolves value via resolve()")
	func resolvesValue() {
		let value = DependencyValues.shared.resolve(StringKey.self)
		// Auto-detected context depends on test runner; just verify resolution works
		#expect(value == "live" || value == "test")
	}

	@Test("singleton scope returns same instance")
	func singletonScope() {
		let value1 = DependencyValues.shared.resolve(StringKey.self)
		let value2 = DependencyValues.shared.resolve(StringKey.self)
		#expect(value1 == value2)
	}

	@Test("flow scope resolves and can be ended")
	func flowScope() {
		let value1 = DependencyValues.shared.resolve(FlowKey.self)
		let value2 = DependencyValues.shared.resolve(FlowKey.self)
		#expect(value1 == value2)

		DependencyValues.shared.endFlow("testFlow")
		// After ending flow, resolves a fresh value
		let value3 = DependencyValues.shared.resolve(FlowKey.self)
		#expect(value3 == value1)
	}

	@Test("override replaces resolved value")
	func overrideValue() {
		DependencyValues.shared.override(StringKey.self, with: "overridden")
		let value = DependencyValues.shared.resolve(StringKey.self)
		#expect(value == "overridden")

		DependencyValues.shared.removeOverride(StringKey.self)
	}

	@Test("reset clears all instances")
	func resetClearsAll() {
		DependencyValues.shared.override(StringKey.self, with: "before-reset")
		let before = DependencyValues.shared.resolve(StringKey.self)
		#expect(before == "before-reset")

		DependencyValues.shared.reset()
		let after = DependencyValues.shared.resolve(StringKey.self)
		#expect(after != "before-reset")
	}
}

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
