//
//  CommonRules.swift
//  FormValidator
//

import Foundation

public enum Rules {

	// MARK: - String Rules

	public static func required(
		message: String = "This field is required"
	) -> AnyValidationRule<String> {
		AnyValidationRule(RequiredRule<String>(message: message))
	}

	public static func minLength(
		_ min: Int,
		message: String? = nil
	) -> AnyValidationRule<String> {
		AnyValidationRule(StringLengthRule(
			min: min,
			message: message ?? "Must be at least \(min) characters"
		))
	}

	public static func maxLength(
		_ max: Int,
		message: String? = nil
	) -> AnyValidationRule<String> {
		AnyValidationRule(StringLengthRule(
			max: max,
			message: message ?? "Must be at most \(max) characters"
		))
	}

	public static func password(
		minLength: Int = 8,
		message: String = "Password must be at least 8 characters"
	) -> AnyValidationRule<String> {
		AnyValidationRule(StringLengthRule.password(minLength: minLength, message: message))
	}

	public static func email(
		message: String = "Please enter a valid email address"
	) -> AnyValidationRule<String> {
		let pattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
		return AnyValidationRule(RegexRule(pattern, message: message))
	}

	public static func regex(
		_ pattern: String,
		message: String
	) -> AnyValidationRule<String> {
		AnyValidationRule(RegexRule(pattern, message: message))
	}

	// MARK: - Bool Rules

	public static func accepted(
		message: String = "This field must be accepted"
	) -> AnyValidationRule<Bool> {
		AnyValidationRule(BoolRule(expected: true, message: message))
	}

	// MARK: - Match Rules

	public static func match<Value: Sendable & Equatable>(
		_ other: FormField<Value>,
		message: String = "Values do not match"
	) -> AnyValidationRule<Value> {
		AnyValidationRule(MatchRule(other, message: message))
	}

	/// Lazy match by field name — resolved automatically by `FormValidator.discoverFields(in:)`.
	///
	/// ```swift
	/// @FormField(rules: [Rules.required(), Rules.matchField("password")], autoValidate: true)
	/// var confirmPassword: String = ""
	/// ```
	public static func matchField<Value: Sendable & Equatable>(
		_ fieldName: String,
		message: String = "Values do not match"
	) -> AnyValidationRule<Value> {
		AnyValidationRule(matchFieldName: fieldName, matchMessage: message)
	}

	/// Type-safe lazy match by KeyPath — resolved automatically by `FormValidator.discoverFields(in:)`.
	///
	/// Preferred over string-based `matchField` — compiler checks that the field exists and has the correct type.
	/// ```swift
	/// @FormField(rules: [Rules.required(), Rules.matchField(\RegisterViewModel._password)], autoValidate: true)
	/// var confirmPassword: String = ""
	/// ```
	public static func matchField<Root, Value: Sendable & Equatable>(
		_ keyPath: KeyPath<Root, FormField<Value>>,
		message: String = "Values do not match"
	) -> AnyValidationRule<Value> {
		AnyValidationRule(
			matchResolver: { target in
				(target as? Root)?[keyPath: keyPath]
			},
			matchMessage: message
		)
	}

	// MARK: - Generic Rules

	public static func custom<Value: Sendable>(
		message: String,
		_ predicate: @escaping @Sendable (Value) -> Bool
	) -> AnyValidationRule<Value> {
		AnyValidationRule(ClosureRule<Value>(message: message, predicate))
	}

	public static func asyncCustom<Value: Sendable>(
		message: String,
		_ predicate: @escaping @Sendable (Value) async -> Bool
	) -> AnyAsyncValidationRule<Value> {
		AnyAsyncValidationRule(AsyncClosureRule<Value>(message: message, predicate))
	}
}
