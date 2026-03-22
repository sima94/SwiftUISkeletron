//
//  FormField.swift
//  FormValidator
//

import Foundation

@MainActor
@propertyWrapper
@Observable
public final class FormField<Value: Sendable & Equatable>: Validatable {

	// MARK: - Wrapped Value

	public var wrappedValue: Value {
		didSet {
			guard wrappedValue != oldValue else { return }
			if autoValidate && isEnabled {
				validate()
			} else if error != nil || !errors.isEmpty {
				clearErrors()
			}
			revalidateDependents()
		}
	}

	public var projectedValue: FormField<Value> { self }

	// MARK: - Validation State

	public private(set) var error: ValidationError?
	public private(set) var errors: [ValidationError] = []
	public private(set) var isValidating: Bool = false

	// MARK: - Configuration

	/// When `false`, `validate()` always returns `true` and clears errors.
	/// Use this to exclude hidden/conditional fields from validation.
	public var isEnabled: Bool = true {
		didSet {
			if !isEnabled {
				clearErrors()
			}
		}
	}

	public let autoValidate: Bool
	public let errorDisplayMode: ErrorDisplayMode

	private var syncRules: [AnyValidationRule<Value>]
	private var asyncRules: [AnyAsyncValidationRule<Value>]
	private var dependents: [any Validatable] = []

	public var hasAsyncRules: Bool { !asyncRules.isEmpty }

	private var matchFieldsResolved: Bool = false

	// MARK: - Init

	public init(
		wrappedValue: Value,
		rules: [AnyValidationRule<Value>] = [],
		asyncRules: [AnyAsyncValidationRule<Value>] = [],
		autoValidate: Bool = false,
		errorDisplayMode: ErrorDisplayMode = .first
	) {
		self.wrappedValue = wrappedValue
		self.syncRules = rules
		self.asyncRules = asyncRules
		self.autoValidate = autoValidate
		self.errorDisplayMode = errorDisplayMode
	}

	// MARK: - Sync Validation

	@discardableResult
	public func validate() -> Bool {
		guard isEnabled else {
			clearErrors()
			return true
		}

		var collectedErrors: [ValidationError] = []

		ruleLoop: for rule in syncRules {
			switch rule.validate(wrappedValue) {
			case .success:
				continue
			case .failure(let err):
				collectedErrors.append(err)
				if errorDisplayMode == .first {
					break ruleLoop
				}
			}
		}

		errors = collectedErrors
		error = collectedErrors.first
		return collectedErrors.isEmpty
	}

	// MARK: - Async Validation

	@discardableResult
	public func validateAsync() async -> Bool {
		guard isEnabled else {
			clearErrors()
			return true
		}

		let syncValid = validate()
		guard syncValid else { return false }

		guard !asyncRules.isEmpty else { return true }

		isValidating = true
		defer { isValidating = false }

		var collectedErrors: [ValidationError] = []

		asyncRuleLoop: for rule in asyncRules {
			switch await rule.validate(wrappedValue) {
			case .success:
				continue
			case .failure(let err):
				collectedErrors.append(err)
				if errorDisplayMode == .first {
					break asyncRuleLoop
				}
			}
		}

		errors.append(contentsOf: collectedErrors)
		error = error ?? collectedErrors.first
		return collectedErrors.isEmpty
	}

	// MARK: - Match

	/// Links this field to another field for equality validation.
	/// - Adds a `MatchRule` that checks values are equal
	/// - When `other` changes, this field automatically re-validates
	///
	/// ```swift
	/// $confirmPassword.match(_password, message: "Passwords do not match")
	/// ```
	public func match(_ other: FormField<Value>, message: String = "Values do not match") {
		addRule(AnyValidationRule(MatchRule(other, message: message)))
		other.dependents.append(self)
	}

	/// Resolves lazy `Rules.matchField(...)` markers into real `MatchRule`s.
	/// Supports both KeyPath-based and string-based resolution.
	/// Called automatically by `FormValidator.discoverFields(in:)`.
	public func resolveMatchFields(target: Any, from fields: [(label: String, value: any Validatable)]) {
		guard !matchFieldsResolved else { return }
		matchFieldsResolved = true

		var resolvedRules: [AnyValidationRule<Value>] = []
		for rule in syncRules {
			guard rule.isLazyMatch, let message = rule.matchMessage else {
				resolvedRules.append(rule)
				continue
			}

			var resolved = false

			// 1. Try KeyPath-based resolution (type-safe)
			if let resolver = rule.matchResolver,
			   let typedTarget = resolver(target) as? FormField<Value> {
				resolvedRules.append(AnyValidationRule(MatchRule(typedTarget, message: message)))
				typedTarget.dependents.append(self)
				resolved = true
			}

			// 2. Fall back to string-based resolution (Mirror label)
			if !resolved, let fieldName = rule.matchFieldName {
				let targetLabel = "_\(fieldName)"
				if let (_, fieldValue) = fields.first(where: { $0.label == targetLabel }),
				   let typedTarget = fieldValue as? FormField<Value> {
					resolvedRules.append(AnyValidationRule(MatchRule(typedTarget, message: message)))
					typedTarget.dependents.append(self)
					resolved = true
				}
			}

			if !resolved {
				// Target field not found — keep the placeholder (will always pass)
				resolvedRules.append(rule)
			}
		}
		syncRules = resolvedRules
	}

	// MARK: - Helpers

	public func clearErrors() {
		error = nil
		errors = []
	}

	public func setError(_ message: String) {
		let validationError = ValidationError(message)
		error = validationError
		errors = [validationError]
	}

	public func addRule(_ rule: AnyValidationRule<Value>) {
		syncRules.append(rule)
	}

	public func addAsyncRule(_ rule: AnyAsyncValidationRule<Value>) {
		asyncRules.append(rule)
	}

	// MARK: - Private

	private func revalidateDependents() {
		for dependent in dependents {
			// Only re-validate dependents that have been validated before (have errors or had errors)
			dependent.validate()
		}
	}
}
