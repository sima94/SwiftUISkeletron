//
//  MatchRule.swift
//  FormValidator
//

import Foundation

/// Validates that a value matches the current value of another `FormField`.
/// Typically used for "confirm password" fields.
///
/// Usage:
/// ```swift
/// $confirmPassword.addRule(Rules.match($password, message: "Passwords do not match"))
/// ```
public struct MatchRule<Value: Sendable & Equatable>: ValidationRule, @unchecked Sendable {

	private let other: FormField<Value>
	public let error: ValidationError

	public init(_ other: FormField<Value>, message: String) {
		self.other = other
		self.error = ValidationError(message)
	}

	public func validate(_ value: Value) -> Result<Void, ValidationError> {
		// Safe: FormField.validate() always calls rules from @MainActor
		MainActor.assumeIsolated {
			value == other.wrappedValue ? .success(()) : .failure(error)
		}
	}
}
