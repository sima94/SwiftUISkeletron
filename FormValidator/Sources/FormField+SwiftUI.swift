//
//  FormField+SwiftUI.swift
//  FormValidator
//

import SwiftUI

extension FormField where Value == String {

	/// The formatted text for display in `Text` labels.
	///
	/// Returns the raw value passed through the formatter's `format(_:)` method.
	/// If no formatter is configured, returns the raw value as-is.
	///
	/// ```swift
	/// Text(viewModel.$iban.displayText)
	/// ```
	public var displayText: String {
		guard let formatter = _formatter as? any TextFormatter else {
			return wrappedValue
		}
		return formatter.format(wrappedValue)
	}

	/// A `Binding<String>` for use with `TextField` that applies live formatting.
	///
	/// The binding stores formatted text in `_formattedText` (observed by SwiftUI)
	/// and syncs the raw (unformatted) value to `wrappedValue` for validation.
	///
	/// ```swift
	/// TextField("IBAN", text: viewModel.$iban.textBinding)
	/// ```
	public var textBinding: Binding<String> {
		Binding(
			get: {
				if self._formatter != nil {
					return self._formattedText
				}
				return self.wrappedValue
			},
			set: { newValue in
				guard let formatter = self._formatter as? any TextFormatter else {
					self.wrappedValue = newValue
					return
				}
				let raw = formatter.unformat(newValue)
				let formatted = formatter.format(raw)
				// Update formatted text first (what TextField displays)
				self._formattedText = formatted
				// Update raw value for validation (triggers didSet → validate)
				// Avoid re-syncing _formattedText from didSet since we already set it
				if self.wrappedValue != raw {
					self.wrappedValue = raw
				}
			}
		)
	}
}
