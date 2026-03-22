//
//  RegexRule.swift
//  FormValidator
//

import Foundation

public struct RegexRule: ValidationRule, @unchecked Sendable {

	public typealias Value = String

	public let pattern: String
	public let trimWhitespace: Bool
	public let error: ValidationError

	public init(
		_ pattern: String,
		trimWhitespace: Bool = true,
		message: String
	) {
		self.pattern = pattern
		self.trimWhitespace = trimWhitespace
		self.error = ValidationError(message)
	}

	public func validate(_ value: String) -> Result<Void, ValidationError> {
		var v = value
		if trimWhitespace {
			v = v.trimmingCharacters(in: .whitespacesAndNewlines)
		}
		guard let regex = try? NSRegularExpression(pattern: pattern) else {
			return .failure(error)
		}
		let range = NSRange(v.startIndex..., in: v)
		let match = regex.firstMatch(in: v, range: range)
		guard let match else { return .failure(error) }
		return match.range == range ? .success(()) : .failure(error)
	}
}
