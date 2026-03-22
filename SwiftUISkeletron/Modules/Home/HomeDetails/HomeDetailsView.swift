//
//  HomeDetailsView.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import SwiftUI

struct HomeDetailsView: View {

	@State var viewModel: HomeDetailsViewModel

	var body: some View {
		VStack {
			Text("Hello, Details!")
			if viewModel.isLoading {
				ProgressView()
			} else {
				Text("\(viewModel.data ?? "")")
			}
			Button("Action") {
				viewModel.showSheetTapped()
			}
		}
		.task {
			await viewModel.fetchData()
		}
	}
}

#Preview {
	HomeDetailsView(viewModel: HomeDetailsViewModel())
}
