//
//  RequiredRule.swift
//  FormValidator
//

import Foundation

public struct RequiredRule<Value: Sendable>: ValidationRule {

	public let error: ValidationError

	public init(message: String = "This field is required") {
		self.error = ValidationError(message)
	}

	public func validate(_ value: Value) -> Result<Void, ValidationError> {
		switch value {
		case let string as String:
			let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
			return trimmed.isEmpty ? .failure(error) : .success(())
		case let optional as any OptionalProtocol:
			return optional.isNil ? .failure(error) : .success(())
		default:
			return .success(())
		}
	}
}

// MARK: - Optional Helper

private protocol OptionalProtocol {
	var isNil: Bool { get }
}

extension Optional: OptionalProtocol {
	var isNil: Bool { self == nil }
}
