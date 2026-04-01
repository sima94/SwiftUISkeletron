//
//  AmountFormatter.swift
//  FormValidator
//

import Foundation

/// Formats numeric strings as currency/amount values with grouping and decimal separators.
///
/// The raw value uses `"."` as decimal separator (e.g., `"1234.56"`).
/// The formatted value uses the configured separators (e.g., `"1.234,56"` for German locale).
///
/// ```swift
/// // Uses Locale.current separators by default
/// let formatter = AmountFormatter()
/// formatter.format("1234.56")    // "1.234,56" (for DE locale)
/// formatter.unformat("1.234,56") // "1234.56"
///
/// // Or with explicit separators
/// let usFormatter = AmountFormatter(groupingSeparator: ",", decimalSeparator: ".", maxDecimalPlaces: 2)
/// ```
public struct AmountFormatter: TextFormatter, Sendable {

	public let groupingSeparator: String
	public let decimalSeparator: String
	public let maxDecimalPlaces: Int

	/// Creates an amount formatter using the given locale's separators.
	///
	/// - Parameters:
	///   - locale: The locale to derive grouping and decimal separators from (default: `.current`).
	///   - maxDecimalPlaces: Maximum number of decimal digits (default: `2`).
	public init(
		locale: Locale = .current,
		maxDecimalPlaces: Int = 2
	) {
		self.groupingSeparator = locale.groupingSeparator ?? "."
		self.decimalSeparator = locale.decimalSeparator ?? ","
		self.maxDecimalPlaces = maxDecimalPlaces
	}

	/// Creates an amount formatter with explicit separators.
	///
	/// - Parameters:
	///   - groupingSeparator: Thousands grouping separator.
	///   - decimalSeparator: Decimal separator.
	///   - maxDecimalPlaces: Maximum number of decimal digits (default: `2`).
	public init(
		groupingSeparator: String,
		decimalSeparator: String,
		maxDecimalPlaces: Int = 2
	) {
		self.groupingSeparator = groupingSeparator
		self.decimalSeparator = decimalSeparator
		self.maxDecimalPlaces = maxDecimalPlaces
	}

	/// Formats a raw value (where `"."` is always the decimal separator) into display format.
	public func format(_ value: String) -> String {
		let sanitized = sanitizeRaw(value)
		guard !sanitized.isEmpty else { return "" }

		let parts = sanitized.split(separator: ".", maxSplits: 1)
		let integerPart = String(parts[0])
		let decimalPart = parts.count > 1 ? String(parts[1]) : nil

		let groupedInteger = groupDigits(integerPart)

		if let decimal = decimalPart {
			return groupedInteger + decimalSeparator + decimal
		}

		// Preserve trailing decimal separator if user just typed it
		if value.hasSuffix(".") {
			return groupedInteger + decimalSeparator
		}

		return groupedInteger
	}

	/// Strips formatted text (with `groupingSeparator`/`decimalSeparator`) back to raw value
	/// where `"."` is the decimal separator.
	public func unformat(_ value: String) -> String {
		// First replace decimal separator with a placeholder, then strip grouping
		let decimalPlaceholder = "\u{FFFF}"
		var cleaned = value

		// Replace decimal separator first (before stripping grouping, in case they overlap)
		if decimalSeparator != "." {
			cleaned = cleaned.replacingOccurrences(of: decimalSeparator, with: decimalPlaceholder)
		} else {
			// When decimal separator is ".", we need to distinguish it from grouping.
			// In formatted text the grouping separator is never "." when decimal is "."
			// (that would be ambiguous), so just strip grouping directly.
		}

		// Strip grouping separators
		cleaned = cleaned.replacingOccurrences(of: groupingSeparator, with: "")

		// Restore decimal placeholder to "."
		if decimalSeparator != "." {
			cleaned = cleaned.replacingOccurrences(of: decimalPlaceholder, with: ".")
		}

		return sanitizeRaw(cleaned)
	}

	// MARK: - Private

	/// Cleans a string to contain only digits and at most one `"."`, then normalizes.
	private func sanitizeRaw(_ value: String) -> String {
		var result = ""
		var hasDecimal = false
		var decimalCount = 0

		for char in value {
			if char.isNumber {
				if hasDecimal {
					guard decimalCount < maxDecimalPlaces else { continue }
					decimalCount += 1
				}
				result.append(char)
			} else if char == "." && !hasDecimal {
				hasDecimal = true
				result.append(char)
			}
		}

		// Strip leading zeros (keep at least one digit before decimal)
		if let dotIndex = result.firstIndex(of: ".") {
			let intPart = String(result[result.startIndex..<dotIndex])
			let stripped = String(intPart.drop(while: { $0 == "0" }))
			let normalizedInt = stripped.isEmpty ? "0" : stripped
			result = normalizedInt + String(result[dotIndex...])
		} else {
			let stripped = String(result.drop(while: { $0 == "0" }))
			result = stripped.isEmpty && !result.isEmpty ? "0" : stripped
		}

		return result
	}

	// MARK: - Private

	private func groupDigits(_ digits: String) -> String {
		guard digits.count > 3 else { return digits }

		var result = ""
		for (index, char) in digits.reversed().enumerated() {
			if index > 0, index % 3 == 0 {
				result.append(contentsOf: groupingSeparator)
			}
			result.append(char)
		}
		return String(result.reversed())
	}
}
