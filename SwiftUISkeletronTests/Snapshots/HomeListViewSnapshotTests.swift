//
//  HomeListViewSnapshotTests.swift
//  SwiftUISkeletronTests
//

import Testing
import SnapshotTesting
import SwiftUI
@testable import SwiftUISkeletron

@MainActor
@Suite("HomeListView Snapshots")
struct HomeListViewSnapshotTests {

	@Test func listWithData_iPhoneSE() {
		let view = HomeListView(
			viewModel: HomeListViewModelMock(
				title: "Home",
				isLoading: false,
				data: [
					HomeListData(title: "Item 1"),
					HomeListData(title: "Item 2"),
					HomeListData(title: "Item 3"),
				]
			)
		)

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhoneSe)
		)
	}

	@Test func listWithData_iPhoneProMax() {
		let view = HomeListView(
			viewModel: HomeListViewModelMock(
				title: "Home",
				isLoading: false,
				data: [
					HomeListData(title: "Item 1"),
					HomeListData(title: "Item 2"),
					HomeListData(title: "Item 3"),
				]
			)
		)

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhone13ProMax)
		)
	}

	@Test func listLoading_iPhoneSE() {
		let view = HomeListView(
			viewModel: HomeListViewModelMock(
				title: "Home",
				isLoading: true,
				data: []
			)
		)

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhoneSe)
		)
	}

	@Test func listLoading_iPhoneProMax() {
		let view = HomeListView(
			viewModel: HomeListViewModelMock(
				title: "Home",
				isLoading: true,
				data: []
			)
		)

		assertSnapshot(
			of: UIHostingController(rootView: view),
			as: .image(on: .iPhone13ProMax)
		)
	}
}
