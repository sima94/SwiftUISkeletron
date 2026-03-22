//
//  HomeViewModel.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import Foundation
import Infuse

@MainActor
@Observable
final class HomeListViewModel: HomeListViewModelProtocol {

	var title = "Hello, World!"
	var isLoading = false
	var data: [HomeListData] = []
	var error: (any Error)?

	@ObservationIgnored
	@Dependency(HomeRepositoryKey.self) var repository

	@ObservationIgnored
	private var observeTask: Task<Void, Never>?

	func startObserving() {
		guard observeTask == nil else { return }
		observeTask = Task { [weak self] in
			guard let self else { return }
			for await items in repository.observe() {
				self.data = items
			}
		}
	}

	func fetchData() async {
		guard !isLoading else { return }
		isLoading = true
		defer { isLoading = false }
		do {
			try await repository.refresh()
		} catch {
			self.error = error
		}
	}

	deinit {
		observeTask?.cancel()
	}
}
