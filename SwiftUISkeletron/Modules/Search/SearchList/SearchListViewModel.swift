//
//  SearchListViewModel.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 7.5.25..
//

import Foundation

@MainActor
protocol SearchListViewModelProtocol {
	var isLoading: Bool { get }
	var searchText: String { get set }
	var items: [String] { get }
	var filteredItems: [String] { get }
	
	func fetchItems() async
}

@MainActor
@Observable
final class SearchListViewModel: SearchListViewModelProtocol {

	var isLoading: Bool = false
	var searchText: String = ""
	var items: [String] = []

	var filteredItems: [String] {
		items.filter { $0.localizedLowercase.starts(with: searchText.localizedLowercase) }
	}

	func fetchItems() async {
		guard !isLoading else { return }
		isLoading = true
		defer { isLoading = false }
		try? await Task.sleep(for: .seconds(3))
		items = Array(1...10000).map(\.description)
	}
}
