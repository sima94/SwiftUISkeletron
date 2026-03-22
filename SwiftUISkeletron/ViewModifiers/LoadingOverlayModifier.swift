//
//  LoadingOverlayModifier.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 20.5.25..
//

import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
	let isLoading: Bool
	let isProgressViewHidden: Bool

	func body(content: Content) -> some View {
		ZStack {
			content
				.disabled(isLoading) // disables interaction with underlying view
				.blur(radius: isLoading ? 1 : 0)

			if isLoading {
				AppColor.overlay
					.ignoresSafeArea()
					.transition(.opacity)

				if !isProgressViewHidden {
					ProgressView()
						.progressViewStyle(CircularProgressViewStyle())
						.padding(Spacing.lg)
						.background(.ultraThinMaterial)
						.cornerRadius(Radius.md)
				}
			}
		}
		.animation(.easeInOut(duration: 0.2), value: isLoading)
	}
}

extension View {
	func loadingOverlay(_ isLoading: Bool, isProgressViewHidden: Bool = true) -> some View {
		self.modifier(LoadingOverlayModifier(isLoading: isLoading, isProgressViewHidden: isProgressViewHidden))
	}
}
