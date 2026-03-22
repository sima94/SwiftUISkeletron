//
//  ProfileView.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import Foundation
import SwiftUI

struct ProfileView: View {

	@State var viewModel: ProfileViewModel
	@State private var router = ProfileRouter()

	var body: some View {
		NavigationStack(path: $router.path) {
			VStack {

				Spacer(minLength: 20)

				Text("Profile")

				Spacer()

				if !viewModel.isLoggedIn {

					Button {
						router.navigate(to: .login)
					} label: {
						Text("Login")
							.padding()
							.frame(maxWidth:.infinity)
					}
					.tint(.white)
					.background(AppColor.primaryAction)

					Button {
						router.navigate(to: .register)
					} label: {
						Text("Register")
							.padding()
							.frame(maxWidth:.infinity)
					}
					.tint(.white)
					.background(AppColor.destructiveAction)
				} else {

					Button {
						Task { await viewModel.logout() }
					} label: {
						Text("Logout")
							.padding()
							.frame(maxWidth:.infinity)
					}
					.tint(.white)
					.background(AppColor.secondaryAction)
				}

				Spacer()
			}
			.padding(Spacing.sm)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						router.navigate(to: .settings)
					}) {
						Image(systemName: "person.circle")
					}
				}
			}
			.navigationDestination(for: ProfileRoute.self) { route in
				switch route {
				case .settings:
					ProfileSettingsView()
				case .login:
					let vm = LoginViewModel()
					LoginView(viewModel: vm)
						.task { await handleLoginEvents(vm) }
				case .register:
					let vm = RegisterViewModel()
					RegisterView(viewModel: vm)
						.task { await handleRegisterEvents(vm) }
				}
			}
		}
	}

	// MARK: - Event Handling

	private func handleLoginEvents(_ viewModel: LoginViewModel) async {
		for await event in viewModel.events {
			switch event {
			case .loginSucceeded:
				router.pop()
			case .showRegister:
				router.navigate(to: .register)
			}
		}
	}

	private func handleRegisterEvents(_ viewModel: RegisterViewModel) async {
		for await event in viewModel.events {
			switch event {
			case .registerSucceeded:
				router.pop()
			}
		}
	}
}
