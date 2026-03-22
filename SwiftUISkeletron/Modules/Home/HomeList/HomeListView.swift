//
//  HomeView.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import Foundation
import SwiftUI

struct HomeListView: View {

	@State var viewModel: HomeListViewModelProtocol
	@State private var router = HomeRouter()

	var body: some View {
		NavigationStack(path: $router.path) {
			Group {
				if viewModel.isLoading && viewModel.data.isEmpty {
					ProgressView()
				} else {
					List {
						Section {
							HStack {
								Image(systemName: "star.fill")
									.foregroundStyle(AppColor.primaryAction)
								Text("Featured")
									.font(.headline)
							}
							.padding(.vertical, Spacing.xs)
						}

						Section {
							ForEach(viewModel.data) { item in
								Button(item.title) {
									router.navigate(to: .details(item))
								}
							}
						}
					}
					.navigationTitle(viewModel.title)
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button(action: {}) {
						Image(systemName: "info.circle")
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						router.showAlert(AlertState(
							title: "Random Alert",
							message: "Number: \(Int.random(in: 1...100))",
							primaryButton: .default("OK"),
							secondaryButton: .cancel()
						))
					}) {
						Image(systemName: "bell")
					}
				}
			}
			.refreshable {
				Task {
					await viewModel.fetchData()
				}
			}
			.task {
				viewModel.startObserving()
				await viewModel.fetchData()
			}
			.navigationDestination(for: HomeRoute.self) { route in
				switch route {
				case .details:
					let vm = HomeDetailsViewModel()
					HomeDetailsView(viewModel: vm)
						.task { await handleHomeDetailsEvents(vm) }
				}
			}
			.routerAlert($router.alert)
			.sheet(item: $router.sheet) { sheet in
				switch sheet {
				case .detailsSheet:
					HomeDetailsSheetView()
				}
			}
		}
	}

	// MARK: - Event Handling

	private func handleHomeDetailsEvents(_ viewModel: HomeDetailsViewModel) async {
		for await event in viewModel.events {
			switch event {
			case .showSheet:
				router.present(.detailsSheet)
			}
		}
	}
}

#Preview {
	HomeListView(
		viewModel: HomeListViewModelMock(title: "Title", isLoading: true, data: [])
	)
}

#Preview {
	HomeListView(
		viewModel: HomeListViewModelMock(title: "Title", isLoading: false, data: [.init(title: "Test"), .init(title: "Test 2")])
	)
}

class HomeListViewModelMock: HomeListViewModelProtocol {
	var title: String
	var isLoading: Bool
	var data: [HomeListData]
	var error: (any Error)?

	init(title: String, isLoading: Bool, data: [HomeListData], error: (any Error)? = nil) {
		self.title = title
		self.isLoading = isLoading
		self.data = data
		self.error = error
	}

	func startObserving() {}
	func fetchData() async {}
}
