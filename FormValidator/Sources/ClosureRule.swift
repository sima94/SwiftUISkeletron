//
//  ClosureRule.swift
//  FormValidator
//

import Foundation

// MARK: - Sync Closure Rule

public struct ClosureRule<Value: Sendable>: ValidationRule, @unchecked Sendable {

	private let closure: @Sendable (Value) -> Result<Void, ValidationError>

	public init(_ closure: @escaping @Sendable (Value) -> Result<Void, ValidationError>) {
		self.closure = closure
	}

	public init(message: String, _ predicate: @escaping @Sendable (Value) -> Bool) {
		let error = ValidationError(message)
		self.closure = { value in
			predicate(value) ? .success(()) : .failure(error)
		}
	}

	public func validate(_ value: Value) -> Result<Void, ValidationError> {
		closure(value)
	}
}

// MARK: - Async Closure Rule

public struct AsyncClosureRule<Value: Sendable>: AsyncValidationRule, @unchecked Sendable {

	private let closure: @Sendable (Value) async -> Result<Void, ValidationError>

	public init(_ closure: @escaping @Sendable (Value) async -> Result<Void, ValidationError>) {
		self.closure = closure
	}

	public init(message: String, _ predicate: @escaping @Sendable (Value) async -> Bool) {
		let error = ValidationError(message)
		self.closure = { value in
			await predicate(value) ? .success(()) : .failure(error)
		}
	}

	public func validate(_ value: Value) async -> Result<Void, ValidationError> {
		await closure(value)
	}
}
