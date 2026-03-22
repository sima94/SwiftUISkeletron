//
//  DependencyValues.swift
//  Infuse
//
//  Created by Stefan Simic on 19. 3. 2026..
//

import Foundation

/// Central resolver for all dependencies.
///
/// Uses `NSRecursiveLock` (same approach as PointFree's swift-dependencies)
/// so that resolving a dependency whose `liveValue`/`testValue` resolves
/// other dependencies on the same thread will not deadlock.
public final class DependencyValues: @unchecked Sendable {

	public static let shared = DependencyValues()

	private let lock = NSRecursiveLock()
	private var singletons: [ObjectIdentifier: Any] = [:]
	private var flowInstances: [FlowID: [ObjectIdentifier: Any]] = [:]
	private var overrides: [ObjectIdentifier: Any] = [:]

	private init() {}

	// MARK: - Resolution

	/// Resolves a dependency by its key type.
	public func resolve<K: DependencyKey>(_ key: K.Type) -> K.Value {
		let id = ObjectIdentifier(key)

		lock.lock()
		defer { lock.unlock() }

		// Check overrides first
		if let override = overrides[id] as? K.Value {
			return override
		}

		switch key.scope {
		case .singleton:
			if let existing = singletons[id] as? K.Value {
				return existing
			}
			let value = Self.resolveValue(for: key)
			singletons[id] = value
			return value

		case .flow(let flowID):
			if let existing = flowInstances[flowID]?[id] as? K.Value {
				return existing
			}
			let value = Self.resolveValue(for: key)
			flowInstances[flowID, default: [:]][id] = value
			return value

		case .transient:
			return Self.resolveValue(for: key)
		}
	}

	// MARK: - Value Resolution

	private static func resolveValue<K: DependencyKey>(for key: K.Type) -> K.Value {
		switch DependencyContext.current {
		case .test: return key.testValue
		case .preview: return key.previewValue
		case .live: return key.liveValue
		}
	}

	// MARK: - Flow Management

	/// Ends a flow, removing all scoped dependencies.
	public func endFlow(_ flowID: FlowID) {
		lock.lock()
		defer { lock.unlock() }
		flowInstances[flowID] = nil
	}

	// MARK: - Overrides (for testing)

	/// Overrides a dependency with a custom value.
	public func override<K: DependencyKey>(_ key: K.Type, with value: K.Value) {
		lock.lock()
		defer { lock.unlock() }
		overrides[ObjectIdentifier(key)] = value
	}

	/// Removes an override for a dependency.
	public func removeOverride<K: DependencyKey>(_ key: K.Type) {
		lock.lock()
		defer { lock.unlock() }
		overrides[ObjectIdentifier(key)] = nil
	}

	// MARK: - Reset

	/// Resets all resolved instances and overrides. Primarily for testing.
	public func reset() {
		lock.lock()
		defer { lock.unlock() }
		singletons.removeAll()
		flowInstances.removeAll()
		overrides.removeAll()
	}
}
