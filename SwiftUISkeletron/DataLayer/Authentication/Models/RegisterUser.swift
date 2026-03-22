//
//  RegisterUser.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 27.5.25..
//

import Foundation

struct RegisterUser: Codable, Sendable {
	var username: String
	var firstName: String
	var lastName: String
	var email: String
	var password: String
}
