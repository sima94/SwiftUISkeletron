//
//  SearchView.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import Foundation
import SwiftUI

struct SearchListView: View {

	@State var viewModel: SearchListViewModelProtocol

	var body: some View {
		NavigationStack {
			Group {
				if viewModel.isLoading && viewModel.items.isEmpty {
					ProgressView()
				} else {
					VStack {
						if viewModel.filteredItems.isEmpty && !viewModel.searchText.isEmpty {
							VStack {
								Image(systemName: "tray")
									.font(.system(size: 50))
									.foregroundColor(.gray)
								Text("No search items available")
									.foregroundColor(.gray)
									.padding(.top, 8)
							}
							.frame(maxWidth: .infinity, maxHeight: .infinity)
						} else {
							List(viewModel.filteredItems, id: \.self) { item in
								Text(item)
							}
							.refreshable {
								Task {
									await viewModel.fetchItems()
								}
							}
						}
					}
					.searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Test search")
				}
			}
			.task {
				await viewModel.fetchItems()
			}
			.animation(.easeInOut, value: viewModel.filteredItems.isEmpty)
			.navigationTitle("Search")
		}
	}
}

#Preview {
	SearchListView(viewModel: SearchListViewModelProtocolMock())
}

class SearchListViewModelProtocolMock : SearchListViewModelProtocol {
	var filteredItems: [String]
	var isLoading: Bool = false
	var items: [String] = []
	var searchText: String = ""

	init(filteredItems: [String] = [], isLoading: Bool = false, items: [String] = [], searchText: String = "") {
		self.filteredItems = filteredItems
		self.isLoading = isLoading
		self.items = items
		self.searchText = searchText
	}

	func fetchItems() async {

	}
}
