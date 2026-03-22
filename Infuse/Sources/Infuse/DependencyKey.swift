//
//  DependencyKey.swift
//  Infuse
//
//  Created by Stefan Simic on 19. 3. 2026..
//

import Foundation

/// Protocol defining a dependency with live and test values.
public protocol DependencyKey {
	associatedtype Value: Sendable

	/// The value used in production.
	static var liveValue: Value { get }

	/// The value used in test targets. Defaults to `liveValue`.
	static var testValue: Value { get }

	/// The scope controlling the dependency's lifetime. Defaults to `.singleton`.
	static var scope: DependencyScope { get }
}

public extension DependencyKey {
	static var testValue: Value { liveValue }
	static var scope: DependencyScope { .singleton }
}
