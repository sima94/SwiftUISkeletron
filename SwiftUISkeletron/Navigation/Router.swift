//
//  Router.swift
//  SwiftUISkeletron
//

import SwiftUI

@MainActor
@Observable
class Router<Route: Hashable, Sheet: Identifiable> {

	var path = NavigationPath()
	var sheet: Sheet?
	var fullScreenCover: Sheet?
	var alert: AlertState?

	// MARK: - Navigation

	func navigate(to route: Route) {
		path.append(route)
	}

	func pop() {
		guard !path.isEmpty else { return }
		path.removeLast()
	}

	func popToRoot() {
		path = NavigationPath()
	}

	// MARK: - Presentation

	func present(_ sheet: Sheet) {
		self.sheet = sheet
	}

	func presentFullScreen(_ cover: Sheet) {
		self.fullScreenCover = cover
	}

	func showAlert(_ alert: AlertState) {
		self.alert = alert
	}

	func dismiss() {
		sheet = nil
		fullScreenCover = nil
	}

	func dismissAlert() {
		alert = nil
	}
}
