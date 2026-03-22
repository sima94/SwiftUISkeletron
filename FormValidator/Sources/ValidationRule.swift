//
//  ValidationRule.swift
//  FormValidator
//

import Foundation

// MARK: - ValidationRule Protocol

public protocol ValidationRule<Value>: Sendable {
	associatedtype Value: Sendable
	func validate(_ value: Value) -> Result<Void, ValidationError>
}

// MARK: - Type Erasure

public struct AnyValidationRule<Value: Sendable>: ValidationRule, @unchecked Sendable {

	private var _validate: @Sendable (Value) -> Result<Void, ValidationError>

	/// Lazy match metadata — resolved by `FormValidator.discoverFields(in:)`.
	internal let matchFieldName: String?
	internal let matchMessage: String?
	/// KeyPath-based lazy match resolver. Takes the target object, returns the matched FormField.
	internal let matchResolver: ((Any) -> (any Validatable)?)?

	public init<R: ValidationRule>(_ rule: R) where R.Value == Value {
		_validate = rule.validate
		matchFieldName = nil
		matchMessage = nil
		matchResolver = nil
	}

	public init(validate: @escaping @Sendable (Value) -> Result<Void, ValidationError>) {
		_validate = validate
		matchFieldName = nil
		matchMessage = nil
		matchResolver = nil
	}

	/// Creates a string-based lazy match marker. Resolved by FormValidator via Mirror field name.
	internal init(matchFieldName: String, matchMessage: String) {
		_validate = { _ in .success(()) }
		self.matchFieldName = matchFieldName
		self.matchMessage = matchMessage
		self.matchResolver = nil
	}

	/// Creates a KeyPath-based lazy match marker. Resolved by FormValidator via the resolver closure.
	internal init(matchResolver: @escaping (Any) -> (any Validatable)?, matchMessage: String) {
		_validate = { _ in .success(()) }
		self.matchFieldName = nil
		self.matchMessage = matchMessage
		self.matchResolver = matchResolver
	}

	public func validate(_ value: Value) -> Result<Void, ValidationError> {
		_validate(value)
	}

	/// Whether this rule is a lazy match marker that needs resolution.
	internal var isLazyMatch: Bool { matchFieldName != nil || matchResolver != nil }
}
