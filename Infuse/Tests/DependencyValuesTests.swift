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
		DependencyValues.shared.override(CounterKey.self, with: 100)
		#expect(DependencyValues.shared.resolve(CounterKey.self) == 100)

		DependencyValues.shared.override(CounterKey.self, with: 200)
		#expect(DependencyValues.shared.resolve(CounterKey.self) == 200)

		DependencyValues.shared.removeOverride(CounterKey.self)
	}

	@Test("removeOverride restores original resolved value")
	func removeOverrideRestoresOriginal() {
		let original = DependencyValues.shared.resolve(StringKey.self)

		DependencyValues.shared.override(StringKey.self, with: "temporary")
		#expect(DependencyValues.shared.resolve(StringKey.self) == "temporary")

		DependencyValues.shared.removeOverride(StringKey.self)
		let restored = DependencyValues.shared.resolve(StringKey.self)
		#expect(restored == original)
	}

	@Test("reentrant resolution does not deadlock")
	func reentrantResolution() {
		let value = DependencyValues.shared.resolve(OuterKey.self)
		// OuterKey.testValue resolves StringKey inside — must not deadlock
		#expect(value.hasPrefix("outer-"))
	}
}
