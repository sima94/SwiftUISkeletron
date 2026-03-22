//
//  StringLengthRule.swift
//  FormValidator
//

import Foundation

public struct StringLengthRule: ValidationRule {

	public typealias Value = String

	public let min: Int
	public let max: Int
	public let trimWhitespace: Bool
	public let error: ValidationError

	public init(
		min: Int = 0,
		max: Int = .max,
		trimWhitespace: Bool = true,
		message: String
	) {
		self.min = min
		self.max = max
		self.trimWhitespace = trimWhitespace
		self.error = ValidationError(message)
	}

	public func validate(_ value: String) -> Result<Void, ValidationError> {
		var v = value
		if trimWhitespace {
			v = v.trimmingCharacters(in: .whitespacesAndNewlines)
		}
		let valid = v.count >= min && v.count <= max
		return valid ? .success(()) : .failure(error)
	}
}

// MARK: - Convenience Factories

extension StringLengthRule {

	public static func password(
		minLength: Int = 8,
		message: String = "Password must be at least 8 characters"
	) -> StringLengthRule {
		StringLengthRule(min: minLength, message: message)
	}
}
