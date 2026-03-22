//
//  LoginView.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 8.5.25..
//

import SwiftUI

struct LoginView: View {

	@State var viewModel: LoginViewModel

	var body: some View {
		VStack {
			Form {
				Text("Login")
				TextField("Username", text: $viewModel.username)
				if let error = viewModel.$username.error?.message {
					Text(error).foregroundColor(AppColor.errorText)
				}

				TextField("Password", text: $viewModel.password)
				if let error = viewModel.$password.error?.message {
					Text(error).foregroundColor(AppColor.errorText)
				}

				Spacer(minLength: 200)
				Text("Test")
			}

			VStack(spacing: Spacing.lg) {
				Button(action: {
					Task {
						await viewModel.login()
					}
				}) {
					VStack {
						if viewModel.isLoginInProgress {
							ProgressView()
						} else {
							Text("Login")
						}
					}
					.padding()
					.frame(maxWidth:.infinity)
				}
				.tint(.white)
				.background(AppColor.primaryAction)

				Button(action: {
					viewModel.registerTapped()
				}) {
					Text("Go to Register")
						.padding()
						.frame(maxWidth:.infinity)
				}
				.tint(.white)
				.background(AppColor.primaryAction)
			}
			.padding(.horizontal, Spacing.lg)
			.padding(.bottom, Spacing.lg)

		}
		.loadingOverlay(viewModel.isLoginInProgress)
		.animation(.easeInOut, value: viewModel.isLoginInProgress)
	}
}

#Preview {
	LoginView(viewModel: LoginViewModel())
}
