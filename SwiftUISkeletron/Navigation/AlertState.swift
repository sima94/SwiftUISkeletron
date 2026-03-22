//
//  AlertState.swift
//  SwiftUISkeletron
//

import SwiftUI

// MARK: - Alert Action

enum AlertAction: Equatable {
	case none
	case custom(String)
}

// MARK: - Alert State

struct AlertState: Equatable {
	let title: String
	var message: String?
	var primaryButton: ButtonState
	var secondaryButton: ButtonState?

	struct ButtonState: Equatable {
		let title: String
		let role: ButtonRole?
		let action: AlertAction

		static func `default`(_ title: String, action: AlertAction = .none) -> ButtonState {
			ButtonState(title: title, role: nil, action: action)
		}

		static func cancel(_ title: String = "Cancel") -> ButtonState {
			ButtonState(title: title, role: .cancel, action: .none)
		}

		static func destructive(_ title: String, action: AlertAction = .none) -> ButtonState {
			ButtonState(title: title, role: .destructive, action: action)
		}

		static func == (lhs: ButtonState, rhs: ButtonState) -> Bool {
			lhs.title == rhs.title && lhs.action == rhs.action
		}
	}
}

// MARK: - View Modifier

extension View {

	func routerAlert(_ alert: Binding<AlertState?>, onAction: @escaping (AlertAction) -> Void = { _ in }) -> some View {
		self.alert(
			alert.wrappedValue?.title ?? "",
			isPresented: Binding(
				get: { alert.wrappedValue != nil },
				set: { if !$0 { alert.wrappedValue = nil } }
			)
		) {
			if let state = alert.wrappedValue {
				Button(state.primaryButton.title, role: state.primaryButton.role) {
					onAction(state.primaryButton.action)
				}
				if let secondary = state.secondaryButton {
					Button(secondary.title, role: secondary.role) {
						onAction(secondary.action)
					}
				}
			}
		} message: {
			if let message = alert.wrappedValue?.message {
				Text(message)
			}
		}
	}
}
