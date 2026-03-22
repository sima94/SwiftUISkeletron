//
//  UserDefault+PropertyWrapper.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 27.5.25..
//

import Foundation

@propertyWrapper
struct UserDefault<Value: Codable>: @unchecked Sendable {
	let key: String
	let container: UserDefaults

	init(key: String, container: UserDefaults = .standard) {
		self.key = key
		self.container = container
	}

	var wrappedValue: Value? {
		get {
			guard let data = container.data(forKey: key) else {
				return container.object(forKey: key) as? Value
			}
			return try? JSONDecoder().decode(Value.self, from: data)
		}
		nonmutating set {
			if let value = newValue {
				if let primitive = value as? any NSSecureCoding {
					container.set(primitive, forKey: key)
				} else if let encoded = try? JSONEncoder().encode(value) {
					container.set(encoded, forKey: key)
				}
			} else {
				container.removeObject(forKey: key)
			}
		}
	}
}

@propertyWrapper
struct UnwrappedUserDefault<Value: Codable>: @unchecked Sendable {
	let key: String
	let defaultValue: Value
	let container: UserDefaults

	init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
		self.key = key
		self.defaultValue = defaultValue
		self.container = container
	}

	var wrappedValue: Value {
		get {
			if let data = container.data(forKey: key),
			   let decoded = try? JSONDecoder().decode(Value.self, from: data) {
				return decoded
			}

			return container.object(forKey: key) as? Value ?? defaultValue
		}
		nonmutating set {
			if let primitive = newValue as? any NSSecureCoding {
				container.set(primitive, forKey: key)
			} else if let encoded = try? JSONEncoder().encode(newValue) {
				container.set(encoded, forKey: key)
			}
		}
	}
}
