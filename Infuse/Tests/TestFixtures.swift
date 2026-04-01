//
//  TestFixtures.swift
//  InfuseTests
//

import Infuse

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

extension DependencyValues {
	var string: String {
		get { self[StringKey.self] }
		set { self[StringKey.self] = newValue }
	}

	var counter: Int {
		get { self[CounterKey.self] }
		set { self[CounterKey.self] = newValue }
	}

	var flow: String {
		get { self[FlowKey.self] }
		set { self[FlowKey.self] = newValue }
	}

	var outer: String {
		get { self[OuterKey.self] }
		set { self[OuterKey.self] = newValue }
	}
}

/// A dependency that resolves another dependency (tests reentrant locking).
struct OuterKey: DependencyKey {
	static var liveValue: String {
		@Dependency(\.string) var inner
		return "outer-\(inner)"
	}
	static var testValue: String {
		@Dependency(\.string) var inner
		return "outer-\(inner)"
	}
}
