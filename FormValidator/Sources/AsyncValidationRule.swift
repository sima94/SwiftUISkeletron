//
//  AsyncValidationRule.swift
//  FormValidator
//

import Foundation

// MARK: - AsyncValidationRule Protocol

public protocol AsyncValidationRule<Value>: Sendable {
	associatedtype Value: Sendable
	func validate(_ value: Value) async -> Result<Void, ValidationError>
}

// MARK: - Type Erasure

public struct AnyAsyncValidationRule<Value: Sendable>: AsyncValidationRule, @unchecked Sendable {

	private let _validate: @Sendable (Value) async -> Result<Void, ValidationError>

	public init<R: AsyncValidationRule>(_ rule: R) where R.Value == Value {
		_validate = rule.validate
	}

	public init(validate: @escaping @Sendable (Value) async -> Result<Void, ValidationError>) {
		_validate = validate
	}

	public func validate(_ value: Value) async -> Result<Void, ValidationError> {
		await _validate(value)
	}
}
