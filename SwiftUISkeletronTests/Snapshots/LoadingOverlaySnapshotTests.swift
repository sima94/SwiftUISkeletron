//
//  LoadingOverlaySnapshotTests.swift
//  SwiftUISkeletronTests
//

import Testing
import SnapshotTesting
import SwiftUI
@testable import SwiftUISkeletron

@MainActor
@Suite("LoadingOverlay Snapshots")
struct LoadingOverlaySnapshotTests {

	@Test func overlayVisible_iPhoneSE() {
		let view = Text("Background Content")
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.loadingOverlay(true, isProgressViewHidden: false)

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhoneSe)
		)
	}

	@Test func overlayVisible_iPhoneProMax() {
		let view = Text("Background Content")
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.loadingOverlay(true, isProgressViewHidden: false)

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhone13ProMax)
		)
	}

	@Test func overlayHidden_iPhoneSE() {
		let view = Text("Background Content")
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.loadingOverlay(false)

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhoneSe)
		)
	}

	@Test func overlayHidden_iPhoneProMax() {
		let view = Text("Background Content")
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.loadingOverlay(false)

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhone13ProMax)
		)
	}
}
