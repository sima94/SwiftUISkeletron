//
//  DependencyScope.swift
//  Infuse
//
//  Created by Stefan Simic on 19. 3. 2026..
//

import Foundation

/// Identifies a dependency flow for scoped lifetime management.
public struct FlowID: Hashable, ExpressibleByStringLiteral, Sendable {
	public let rawValue: String

	public init(stringLiteral value: String) {
		self.rawValue = value
	}

	public init(_ rawValue: String) {
		self.rawValue = rawValue
	}
}

/// Controls the lifetime of a resolved dependency.
public enum DependencyScope: Sendable {
	/// Single instance shared across the entire app.
	case singleton
	/// Instance scoped to a flow, cleaned up when the flow ends.
	case flow(FlowID)
	/// New instance created every time the dependency is resolved.
	case transient
}
