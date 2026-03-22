//
//  Validatable.swift
//  FormValidator
//

import Foundation

@MainActor
public protocol Validatable: AnyObject {
	@discardableResult
	func validate() -> Bool
	func validateAsync() async -> Bool
	var hasAsyncRules: Bool { get }
	var isEnabled: Bool { get }

	/// Resolves lazy match rules (`Rules.matchField(...)`) by finding
	/// the target field. Called by `FormValidator.discoverFields(in:)`.
	func resolveMatchFields(target: Any, from fields: [(label: String, value: any Validatable)])
}

extension Validatable {
	public func resolveMatchFields(target: Any, from fields: [(label: String, value: any Validatable)]) {}
}
