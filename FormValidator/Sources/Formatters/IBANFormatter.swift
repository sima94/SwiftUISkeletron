//
//  IBANFormatter.swift
//  FormValidator
//

/// Formats IBAN strings into groups of 4 characters separated by spaces.
///
/// ```swift
/// let formatter = IBANFormatter()
/// formatter.format("DE89370400440532013000")       // "DE89 3704 0044 0532 0130 00"
/// formatter.unformat("DE89 3704 0044 0532 0130 00") // "DE89370400440532013000"
/// ```
public struct IBANFormatter: TextFormatter, Sendable {

	/// Maximum number of raw characters (without spaces). Standard IBAN max is 34.
	public let maxLength: Int

	public init(maxLength: Int = 34) {
		self.maxLength = maxLength
	}

	public func format(_ value: String) -> String {
		let raw = unformat(value)
		var result = ""
		for (index, character) in raw.enumerated() {
			if index > 0, index % 4 == 0 {
				result.append(" ")
			}
			result.append(character)
		}
		return result
	}

	public func unformat(_ value: String) -> String {
		let stripped = value
			.replacingOccurrences(of: " ", with: "")
			.uppercased()
		if stripped.count > maxLength {
			return String(stripped.prefix(maxLength))
		}
		return stripped
	}
}
