//
//  PhoneFormatter.swift
//  FormValidator
//

/// Formats phone numbers using a pattern-based mask.
///
/// Use `#` as a digit placeholder in the pattern. Non-placeholder characters
/// (spaces, dashes, parentheses) are inserted automatically.
///
/// ```swift
/// let formatter = PhoneFormatter(pattern: "+### ## ### ####")
/// formatter.format("381631234567")         // "+381 63 123 4567"
/// formatter.unformat("+381 63 123 4567")   // "381631234567"
/// ```
public struct PhoneFormatter: TextFormatter, Sendable {

	/// The mask pattern where `#` represents a digit placeholder.
	public let pattern: String

	/// Creates a phone formatter with the given pattern.
	///
	/// - Parameter pattern: A mask string using `#` for digit placeholders.
	///   Example: `"+### ## ### ####"` or `"+# (###) ###-####"`.
	public init(pattern: String = "+### ## ### ####") {
		self.pattern = pattern
	}

	public func format(_ value: String) -> String {
		let digits = extractDigits(from: value)
		guard !digits.isEmpty else { return "" }

		var result = ""
		var digitIndex = digits.startIndex

		for patternChar in pattern {
			guard digitIndex < digits.endIndex else { break }

			if patternChar == "#" {
				result.append(digits[digitIndex])
				digitIndex = digits.index(after: digitIndex)
			} else {
				result.append(patternChar)
			}
		}

		return result
	}

	public func unformat(_ value: String) -> String {
		extractDigits(from: value)
	}

	// MARK: - Private

	private func extractDigits(from value: String) -> String {
		let maxDigits = pattern.filter({ $0 == "#" }).count
		let digits = String(value.filter(\.isNumber))
		if digits.count > maxDigits {
			return String(digits.prefix(maxDigits))
		}
		return digits
	}
}
