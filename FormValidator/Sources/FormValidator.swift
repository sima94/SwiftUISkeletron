//
//  FormValidator.swift
//  FormValidator
//

import Foundation

@MainActor
@Observable
public final class FormValidator {

	public var isValid: Bool = true

	// MARK: - Field Storage

	private var registeredFields: [any Validatable] = []
	private var discoveredFields: [any Validatable]?
	private var target: Any?

	/// All active fields: registered + discovered, filtered by `isEnabled`.
	private var fields: [any Validatable] {
		let all = registeredFields + (discoveredFields ?? [])
		return all.filter { $0.isEnabled }
	}

	// MARK: - Init

	public init() {}

	// MARK: - Auto-Discovery (Lazy)

	/// Discovers all `@FormField` properties in the target using Mirror.
	/// Fields are cached after first discovery.
	/// Also resolves lazy match rules (e.g., `Rules.matchField("password")`).
	public func discoverFields(in target: Any) {
		self.target = target
		let mirror = Mirror(reflecting: target)
		let labeledFields = mirror.children.compactMap { child -> (label: String, value: any Validatable)? in
			guard let label = child.label, let field = child.value as? (any Validatable) else { return nil }
			return (label, field)
		}
		discoveredFields = labeledFields.map(\.value)

		// Resolve lazy match rules (Rules.matchField by string or KeyPath)
		for (_, field) in labeledFields {
			field.resolveMatchFields(target: target, from: labeledFields)
		}
	}

	/// Clears the cached field list. Next `validate()` will re-discover.
	public func invalidateFieldCache() {
		discoveredFields = nil
	}

	// MARK: - Manual Registration

	public func register(_ field: any Validatable) {
		registeredFields.append(field)
	}

	// MARK: - Sync Validation

	/// Validates all fields. Pass `in: self` from ViewModel to enable lazy auto-discovery.
	@discardableResult
	public func validate(in target: Any? = nil) -> Bool {
		if let target, discoveredFields == nil {
			discoverFields(in: target)
		}
		var allValid = true
		for field in fields {
			if !field.validate() {
				allValid = false
			}
		}
		isValid = allValid
		return allValid
	}

	// MARK: - Async Validation

	@discardableResult
	public func validateAsync(in target: Any? = nil) async -> Bool {
		if let target, discoveredFields == nil {
			discoverFields(in: target)
		}

		var allValid = true
		for field in fields {
			if !field.validate() {
				allValid = false
			}
		}

		for field in fields where field.hasAsyncRules {
			if !(await field.validateAsync()) {
				allValid = false
			}
		}

		isValid = allValid
		return allValid
	}
}
