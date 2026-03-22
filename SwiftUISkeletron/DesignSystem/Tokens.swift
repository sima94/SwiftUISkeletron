//
//  Tokens.swift
//  SwiftUISkeletron
//

import SwiftUI

// MARK: - Spacing

enum Spacing {
	static let xxs: CGFloat = 4
	static let xs: CGFloat = 8
	static let sm: CGFloat = 12
	static let md: CGFloat = 16
	static let lg: CGFloat = 24
	static let xl: CGFloat = 32
	static let xxl: CGFloat = 48
}

// MARK: - AppColor

enum AppColor {
	static let primaryAction = Color.accentColor
	static let destructiveAction = Color.red
	static let secondaryAction = Color.secondary
	static let background = Color(.systemBackground)
	static let secondaryBackground = Color(.secondarySystemBackground)
	static let overlay = Color.black.opacity(0.4)
	static let errorText = Color.red
}

// MARK: - Radius

enum Radius {
	static let sm: CGFloat = 8
	static let md: CGFloat = 12
	static let lg: CGFloat = 16
}
