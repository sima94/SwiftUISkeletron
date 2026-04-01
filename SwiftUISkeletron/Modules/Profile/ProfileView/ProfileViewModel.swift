//
//  ProfileViewModel.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 7.5.25..
//

import Foundation
import Infuse

@MainActor
@Observable
final class ProfileViewModel {

	var isLoggedIn: Bool { loginState.isLoggedIn }

	@ObservationIgnored
	@Dependency(\.loginState) var loginState

	func logout() async {
		await loginState.logout()
	}
}
