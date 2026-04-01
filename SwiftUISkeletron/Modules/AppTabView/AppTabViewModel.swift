//
//  AppTabViewModel.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 20.5.25..
//

import Foundation
import Infuse

@MainActor
protocol AppTabViewModelProtocol {
	var isLoggedIn: Bool { get }
}

@MainActor
@Observable
final class AppTabViewModel: AppTabViewModelProtocol {

	var isLoggedIn: Bool { loginState.isLoggedIn }

	@ObservationIgnored
	@Dependency(\.loginState) var loginState

	init() {
		loginState.startObserving()
	}
}
