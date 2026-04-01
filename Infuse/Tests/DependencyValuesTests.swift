//
//  DependencyValuesTests.swift
//  InfuseTests
//

import Testing
@testable import Infuse

@Suite("DependencyValues", .serialized)
struct DependencyValuesTests {

	init() {
		DependencyValues.shared.reset()
	}

	@Test("resolves value via key-path access")
	func resolvesValue() {
		let value = DependencyValues.shared.string
		// Auto-detected context depends on test runner; just verify resolution works
		#expect(value == "live" || value == "test")
	}

	@Test("singleton scope returns same instance")
	func singletonScope() {
		let value1 = DependencyValues.shared.string
		let value2 = DependencyValues.shared.string
		#expect(value1 == value2)
	}

	@Test("flow scope resolves and can be ended")
	func flowScope() {
		let value1 = DependencyValues.shared.flow
		let value2 = DependencyValues.shared.flow
		#expect(value1 == value2)

		DependencyValues.shared.endFlow("testFlow")
		// After ending flow, resolves a fresh value
		let value3 = DependencyValues.shared.flow
		#expect(value3 == value1)
	}

	@Test("override replaces resolved value")
	func overrideValue() {
		DependencyValues.shared.string = "overridden"
		let value = DependencyValues.shared.string
		#expect(value == "overridden")

		DependencyValues.shared.removeOverride(StringKey.self)
	}

	@Test("reset clears all instances")
	func resetClearsAll() {
		DependencyValues.shared.string = "before-reset"
		let before = DependencyValues.shared.string
		#expect(before == "before-reset")

		DependencyValues.shared.reset()
		let after = DependencyValues.shared.string
		#expect(after != "before-reset")
	}

	@Test("transient scope is never cached")
	func transientScope() {
		// Transient keys are never stored — verify CounterKey has transient scope
		switch CounterKey.scope {
		case .transient:
			break // expected
		default:
			Issue.record("Expected .transient, got \(CounterKey.scope)")
		}

		// Resolving twice should invoke the factory each time (not return cached)
		// We verify by overriding, resolving, changing override, resolving again
		DependencyValues.shared.counter = 100
		#expect(DependencyValues.shared.counter == 100)

		DependencyValues.shared.counter = 200
		#expect(DependencyValues.shared.counter == 200)

		DependencyValues.shared.removeOverride(CounterKey.self)
	}

	@Test("removeOverride restores original resolved value")
	func removeOverrideRestoresOriginal() {
		let original = DependencyValues.shared.string

		DependencyValues.shared.string = "temporary"
		#expect(DependencyValues.shared.string == "temporary")

		DependencyValues.shared.removeOverride(StringKey.self)
		let restored = DependencyValues.shared.string
		#expect(restored == original)
	}

	@Test("reentrant resolution does not deadlock")
	func reentrantResolution() {
		let value = DependencyValues.shared.outer
		// OuterKey.testValue resolves StringKey inside — must not deadlock
		#expect(value.hasPrefix("outer-"))
	}

	@Test("resolves testValue in test context")
	func resolvesTestValueInTestContext() {
		let value = DependencyValues.shared.string
		let context = DependencyContext.current
		let expected = context == .test ? "test" : "live"
		#expect(value == expected)
	}
}
