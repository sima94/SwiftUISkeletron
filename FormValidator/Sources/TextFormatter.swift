//
//  TextFormatter.swift
//  FormValidator
//

/// A protocol for formatting and unformatting text values.
///
/// Use conforming types to transform raw values for display (e.g., IBAN grouping,
/// phone number masking, currency formatting) and to strip formatting back to raw values
/// for storage and validation.
///
/// ```swift
/// let formatter = IBANFormatter()
/// formatter.format("DE89370400440532013000")    // "DE89 3704 0044 0532 0130 00"
/// formatter.unformat("DE89 3704 0044 0532 0130 00") // "DE89370400440532013000"
/// ```
public protocol TextFormatter: Sendable {

	/// Transforms a raw value into a display-formatted string.
	///
	/// - Parameter value: The raw, unformatted value.
	/// - Returns: The formatted string suitable for display in labels or text fields.
	func format(_ value: String) -> String

	/// Strips formatting from a display string to recover the raw value.
	///
	/// - Parameter value: The formatted display string.
	/// - Returns: The raw value suitable for storage and validation.
	func unformat(_ value: String) -> String
}
