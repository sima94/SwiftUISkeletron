//
//  AppTabView.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import SwiftUI

struct AppTabView: View {

	@State private var viewModel = AppTabViewModel()

	var body: some View {
		TabView {
			HomeListView(viewModel: HomeListViewModel())
				.tabItem {
					Label("Home", systemImage: "house.fill")
				}

			if viewModel.isLoggedIn {
				SearchListView(viewModel: SearchListViewModel())
					.tabItem {
						Label("Search", systemImage: "magnifyingglass")
					}
			}

			ProfileView(viewModel: ProfileViewModel())
				.tabItem {
					Label("Profile", systemImage: "person.fill")
				}
		}
	}
}

#Preview {
	AppTabView()
}
