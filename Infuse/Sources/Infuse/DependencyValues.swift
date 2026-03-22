//
//  DependencyValues.swift
//  Infuse
//
//  Created by Stefan Simic on 19. 3. 2026..
//

import Foundation

/// Central resolver for all dependencies.
public final class DependencyValues: @unchecked Sendable {

	public static let shared = DependencyValues()

	private let lock = NSLock()
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

		let context = DependencyContext.current

		switch key.scope {
		case .singleton:
			if let existing = singletons[id] as? K.Value {
				return existing
			}
			let value = context == .test ? key.testValue : key.liveValue
			singletons[id] = value
			return value

		case .flow(let flowID):
			if let existing = flowInstances[flowID]?[id] as? K.Value {
				return existing
			}
			let value = context == .test ? key.testValue : key.liveValue
			flowInstances[flowID, default: [:]][id] = value
			return value

		case .transient:
			return context == .test ? key.testValue : key.liveValue
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
