//
//  Dependency.swift
//  Infuse
//
//  Created by Stefan Simic on 19. 3. 2026..
//

import Foundation

/// Property wrapper that lazily resolves a dependency from `DependencyValues`.
@propertyWrapper
public struct Dependency<Value: Sendable>: @unchecked Sendable {

	private let resolve: @Sendable () -> Value
	private var resolved: Value?

	public init<K: DependencyKey>(_ key: K.Type) where K.Value == Value {
		self.resolve = { @Sendable in DependencyValues.shared.resolve(K.self) }
	}

	public var wrappedValue: Value {
		mutating get {
			if let resolved {
				return resolved
			}
			let value = resolve()
			resolved = value
			return value
		}
	}
}
