//
//  ValidationError.swift
//  FormValidator
//

import Foundation

public struct ValidationError: Error, Sendable, Equatable, Identifiable {

	public let id: String
	public let message: String

	public init(_ message: String, id: String = UUID().uuidString) {
		self.message = message
		self.id = id
	}

	public static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
		lhs.message == rhs.message
	}
}
