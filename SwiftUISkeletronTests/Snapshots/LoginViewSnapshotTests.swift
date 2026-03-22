//
//  LoginViewSnapshotTests.swift
//  SwiftUISkeletronTests
//

import Testing
import SnapshotTesting
import SwiftUI
@testable import SwiftUISkeletron

@MainActor
@Suite("LoginView Snapshots")
struct LoginViewSnapshotTests {

	@Test func defaultState_iPhoneSE() {
		let view = LoginView(viewModel: LoginViewModel())

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhoneSe)
		)
	}

	@Test func defaultState_iPhoneProMax() {
		let view = LoginView(viewModel: LoginViewModel())

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhone13ProMax)
		)
	}
}
