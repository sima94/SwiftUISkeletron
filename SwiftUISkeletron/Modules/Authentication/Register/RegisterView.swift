//
//  RegisterView.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 8.5.25..
//

import SwiftUI

struct RegisterView: View {

	@State var viewModel: RegisterViewModel

	var body: some View {
		VStack {
			Form {
				Text("Register")

				Section {
					TextField("Username", text: $viewModel.username)
					if let error = viewModel.$username.error?.message {
						Text(error).foregroundColor(AppColor.errorText)
					}

					TextField("First Name", text: $viewModel.firstName)
					if let error = viewModel.$firstName.error?.message {
						Text(error).foregroundColor(AppColor.errorText)
					}

					TextField("Last Name", text: $viewModel.lastName)
					if let error = viewModel.$lastName.error?.message {
						Text(error).foregroundColor(AppColor.errorText)
					}
				}

				Section {
					TextField("Email", text: $viewModel.email)
					if let error = viewModel.$email.error?.message {
						Text(error).foregroundColor(AppColor.errorText)
					}

					SecureField("Password", text: $viewModel.password)
					if let error = viewModel.$password.error?.message {
						Text(error).foregroundColor(AppColor.errorText)
					}

					SecureField("Confirm Password", text: $viewModel.confirmPassword)
					if let error = viewModel.$confirmPassword.error?.message {
						Text(error).foregroundColor(AppColor.errorText)
					}
				}
			}

			Button(action: {
				Task {
					await viewModel.register()
				}
			}) {
				VStack {
					if viewModel.isLoading {
						ProgressView()
					} else {
						Text("Register")
					}
				}
				.padding()
				.frame(maxWidth: .infinity)
			}
			.tint(.white)
			.background(AppColor.primaryAction)
			.padding(.horizontal, Spacing.lg)
			.padding(.bottom, Spacing.lg)
		}
		.loadingOverlay(viewModel.isLoading)
		.animation(.easeInOut, value: viewModel.isLoading)
	}
}

#Preview {
	RegisterView(viewModel: RegisterViewModel())
}
