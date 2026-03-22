//
//  DependencyValues.swift
//  Infuse
//
//  Created by Stefan Simic on 19. 3. 2026..
//

import os

/// Central resolver for all dependencies.
public final class DependencyValues: @unchecked Sendable {

	public static let shared = DependencyValues()

	private struct State: @unchecked Sendable {
		var singletons: [ObjectIdentifier: Any] = [:]
		var flowInstances: [FlowID: [ObjectIdentifier: Any]] = [:]
		var overrides: [ObjectIdentifier: Any] = [:]
	}

	private let state = OSAllocatedUnfairLock(initialState: State())

	private init() {}

	// MARK: - Resolution

	/// Resolves a dependency by its key type.
	public func resolve<K: DependencyKey>(_ key: K.Type) -> K.Value {
		let id = ObjectIdentifier(key)
		let context = DependencyContext.current

		return state.withLock { state in
			// Check overrides first
			if let override = state.overrides[id] as? K.Value {
				return override
			}

			switch key.scope {
			case .singleton:
				if let existing = state.singletons[id] as? K.Value {
					return existing
				}
				let value = context == .test ? key.testValue : key.liveValue
				state.singletons[id] = value
				return value

			case .flow(let flowID):
				if let existing = state.flowInstances[flowID]?[id] as? K.Value {
					return existing
				}
				let value = context == .test ? key.testValue : key.liveValue
				state.flowInstances[flowID, default: [:]][id] = value
				return value

			case .transient:
				return context == .test ? key.testValue : key.liveValue
			}
		}
	}

	// MARK: - Flow Management

	/// Ends a flow, removing all scoped dependencies.
	public func endFlow(_ flowID: FlowID) {
		state.withLock { state in
			state.flowInstances[flowID] = nil
		}
	}

	// MARK: - Overrides (for testing)

	/// Overrides a dependency with a custom value.
	public func override<K: DependencyKey>(_ key: K.Type, with value: K.Value) {
		state.withLock { state in
			state.overrides[ObjectIdentifier(key)] = value
		}
	}

	/// Removes an override for a dependency.
	public func removeOverride<K: DependencyKey>(_ key: K.Type) {
		state.withLock { state in
			state.overrides[ObjectIdentifier(key)] = nil
		}
	}

	// MARK: - Reset

	/// Resets all resolved instances and overrides. Primarily for testing.
	public func reset() {
		state.withLock { state in
			state.singletons.removeAll()
			state.flowInstances.removeAll()
			state.overrides.removeAll()
		}
	}
}
