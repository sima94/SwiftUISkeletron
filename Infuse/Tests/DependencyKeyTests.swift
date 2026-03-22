//
//  DependencyKeyTests.swift
//  InfuseTests
//

import Testing
@testable import Infuse

// MARK: - Fixture that only provides liveValue (uses defaults)

private struct DefaultsOnlyKey: DependencyKey {
	static var liveValue: String { "default-live" }
}

// MARK: - Tests

@Suite("DependencyKey defaults")
struct DependencyKeyTests {

	@Test("testValue defaults to liveValue when not overridden")
	func testValueFallsBackToLiveValue() {
		#expect(DefaultsOnlyKey.testValue == DefaultsOnlyKey.liveValue)
		#expect(DefaultsOnlyKey.testValue == "default-live")
	}

	@Test("scope defaults to singleton")
	func scopeDefaultsToSingleton() {
		switch DefaultsOnlyKey.scope {
		case .singleton:
			break // expected
		default:
			Issue.record("Expected .singleton, got \(DefaultsOnlyKey.scope)")
		}
	}

	@Test("custom testValue overrides default")
	func customTestValueOverridesDefault() {
		#expect(StringKey.liveValue == "live")
		#expect(StringKey.testValue == "test")
		#expect(StringKey.testValue != StringKey.liveValue)
	}

	@Test("custom scope overrides default")
	func customScopeOverridesDefault() {
		switch CounterKey.scope {
		case .transient:
			break // expected
		default:
			Issue.record("Expected .transient, got \(CounterKey.scope)")
		}
	}
}
