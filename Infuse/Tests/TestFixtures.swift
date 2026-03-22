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
