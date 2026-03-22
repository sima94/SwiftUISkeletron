//
//  BoolRule.swift
//  FormValidator
//

import Foundation

public struct BoolRule: ValidationRule {

	public typealias Value = Bool

	public let expected: Bool
	public let error: ValidationError

	public init(
		expected: Bool = true,
		message: String = "This field must be accepted"
	) {
		self.expected = expected
		self.error = ValidationError(message)
	}

	public func validate(_ value: Bool) -> Result<Void, ValidationError> {
		value == expected ? .success(()) : .failure(error)
	}
}
