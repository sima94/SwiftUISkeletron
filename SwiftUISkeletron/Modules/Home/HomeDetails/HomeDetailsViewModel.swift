//
//  HomeDetailsViewModel.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import Foundation
import Observation
import SwiftUI
import Infuse

@MainActor
@Observable
final class HomeDetailsViewModel: HomeDetailsViewModelProtocol {

	// MARK: - Events

	enum Event {
		case showSheet
	}

	private let eventContinuation: AsyncStream<Event>.Continuation
	let events: AsyncStream<Event>

	// MARK: - State

	var isLoading: Bool = false
	var data: String?

	@ObservationIgnored
	@Dependency(HomeNetworkServiceKey.self) var homeService

	// MARK: - Init

	init() {
		var continuation: AsyncStream<Event>.Continuation!
		events = AsyncStream { continuation = $0 }
		eventContinuation = continuation
	}

	// MARK: - Actions

	func fetchData() async {
		isLoading = true
		defer { isLoading = false }

		try? await Task.sleep(for: .seconds(2))

		if let item = try? await homeService.fetchHomeDetailData(id: 1) {
			data = item.title + "\n" + item.subtitle + "\n" + item.description
		}
	}

	func showSheetTapped() {
		eventContinuation.yield(.showSheet)
	}
}
