//
//  RouterTests.swift
//  SwiftUISkeletronTests
//

import Testing
import SwiftUI
@testable import SwiftUISkeletron

// MARK: - Test Helpers

private enum TestRoute: Hashable {
	case home
	case details(Int)
	case settings
}

private enum TestSheet: Identifiable {
	case share
	case edit

	var id: Int {
		switch self {
		case .share: return 0
		case .edit: return 1
		}
	}
}

private typealias TestRouter = Router<TestRoute, TestSheet>

// MARK: - Navigation Tests

@Suite("Router Navigation")
struct RouterNavigationTests {

	@MainActor
	@Test("Navigate appends route to path")
	func navigateAppendsToPath() {
		let router = TestRouter()
		router.navigate(to: .home)
		#expect(router.path.count == 1)
	}

	@MainActor
	@Test("Multiple navigations stack routes")
	func multipleNavigations() {
		let router = TestRouter()
		router.navigate(to: .home)
		router.navigate(to: .details(1))
		router.navigate(to: .settings)
		#expect(router.path.count == 3)
	}

	@MainActor
	@Test("Pop removes last route")
	func popRemovesLast() {
		let router = TestRouter()
		router.navigate(to: .home)
		router.navigate(to: .details(1))
		router.pop()
		#expect(router.path.count == 1)
	}

	@MainActor
	@Test("Pop on empty path does nothing")
	func popEmptyPath() {
		let router = TestRouter()
		router.pop()
		#expect(router.path.count == 0)
	}

	@MainActor
	@Test("PopToRoot clears entire path")
	func popToRoot() {
		let router = TestRouter()
		router.navigate(to: .home)
		router.navigate(to: .details(1))
		router.navigate(to: .settings)
		router.popToRoot()
		#expect(router.path.count == 0)
	}

	@MainActor
	@Test("PopToRoot on empty path does nothing")
	func popToRootEmpty() {
		let router = TestRouter()
		router.popToRoot()
		#expect(router.path.count == 0)
	}
}

// MARK: - Sheet Tests

@Suite("Router Sheets")
struct RouterSheetTests {

	@MainActor
	@Test("Present sets sheet")
	func presentSetsSheet() {
		let router = TestRouter()
		router.present(.share)
		#expect(router.sheet?.id == TestSheet.share.id)
	}

	@MainActor
	@Test("PresentFullScreen sets fullScreenCover")
	func presentFullScreen() {
		let router = TestRouter()
		router.presentFullScreen(.edit)
		#expect(router.fullScreenCover?.id == TestSheet.edit.id)
	}

	@MainActor
	@Test("Present replaces existing sheet")
	func presentReplacesSheet() {
		let router = TestRouter()
		router.present(.share)
		router.present(.edit)
		#expect(router.sheet?.id == TestSheet.edit.id)
	}

	@MainActor
	@Test("Dismiss clears sheet and fullScreenCover")
	func dismissClearsBoth() {
		let router = TestRouter()
		router.present(.share)
		router.presentFullScreen(.edit)
		router.dismiss()
		#expect(router.sheet == nil)
		#expect(router.fullScreenCover == nil)
	}

	@MainActor
	@Test("Dismiss does not affect path")
	func dismissKeepsPath() {
		let router = TestRouter()
		router.navigate(to: .home)
		router.present(.share)
		router.dismiss()
		#expect(router.path.count == 1)
		#expect(router.sheet == nil)
	}

	@MainActor
	@Test("Sheet is nil by default")
	func sheetNilByDefault() {
		let router = TestRouter()
		#expect(router.sheet == nil)
		#expect(router.fullScreenCover == nil)
	}
}

// MARK: - Alert Tests

@Suite("Router Alerts")
struct RouterAlertTests {

	@MainActor
	@Test("ShowAlert sets alert")
	func showAlertSetsAlert() {
		let router = TestRouter()
		let alert = AlertState(
			title: "Test",
			primaryButton: .default("OK")
		)
		router.showAlert(alert)
		#expect(router.alert == alert)
	}

	@MainActor
	@Test("DismissAlert clears alert")
	func dismissAlertClearsAlert() {
		let router = TestRouter()
		router.showAlert(AlertState(title: "Test", primaryButton: .default("OK")))
		router.dismissAlert()
		#expect(router.alert == nil)
	}

	@MainActor
	@Test("Alert is nil by default")
	func alertNilByDefault() {
		let router = TestRouter()
		#expect(router.alert == nil)
	}

	@MainActor
	@Test("Dismiss does not affect alert")
	func dismissKeepsAlert() {
		let router = TestRouter()
		router.showAlert(AlertState(title: "Test", primaryButton: .default("OK")))
		router.dismiss()
		#expect(router.alert != nil)
	}

	@MainActor
	@Test("DismissAlert does not affect sheets")
	func dismissAlertKeepsSheets() {
		let router = TestRouter()
		router.present(.share)
		router.showAlert(AlertState(title: "Test", primaryButton: .default("OK")))
		router.dismissAlert()
		#expect(router.sheet?.id == TestSheet.share.id)
		#expect(router.alert == nil)
	}
}

// MARK: - Never Sheet Tests

@Suite("Router with Never Sheet")
struct RouterNeverSheetTests {

	private typealias NoSheetRouter = Router<TestRoute, Never>

	@MainActor
	@Test("Navigate works without sheet type")
	func navigateWorks() {
		let router = NoSheetRouter()
		router.navigate(to: .home)
		router.navigate(to: .details(42))
		#expect(router.path.count == 2)
	}

	@MainActor
	@Test("Pop works without sheet type")
	func popWorks() {
		let router = NoSheetRouter()
		router.navigate(to: .home)
		router.pop()
		#expect(router.path.count == 0)
	}

	@MainActor
	@Test("Alert works without sheet type")
	func alertWorks() {
		let router = NoSheetRouter()
		router.showAlert(AlertState(title: "Error", primaryButton: .default("OK")))
		#expect(router.alert?.title == "Error")
	}
}
