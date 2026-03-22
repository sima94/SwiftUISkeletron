//
//  DependencyScopeTests.swift
//  InfuseTests
//

import Testing
@testable import Infuse

@Suite("FlowID")
struct FlowIDTests {

	@Test("init with string literal")
	func stringLiteralInit() {
		let flowID: FlowID = "myFlow"
		#expect(flowID.rawValue == "myFlow")
	}

	@Test("init with rawValue parameter")
	func rawValueInit() {
		let flowID = FlowID("anotherFlow")
		#expect(flowID.rawValue == "anotherFlow")
	}

	@Test("equal FlowIDs with same rawValue")
	func equality() {
		let a: FlowID = "login"
		let b = FlowID("login")
		#expect(a == b)
	}

	@Test("different FlowIDs are not equal")
	func inequality() {
		let a: FlowID = "login"
		let b: FlowID = "onboarding"
		#expect(a != b)
	}

	@Test("can be used as dictionary key")
	func hashable() {
		let flowID: FlowID = "key"
		var dict: [FlowID: String] = [:]
		dict[flowID] = "value"
		#expect(dict[flowID] == "value")
	}
}
