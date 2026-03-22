//
//  LoginResponce.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 27.5.25..
//

import Foundation

struct LoginResponse: Codable, Sendable {
	let token: String
	let refreshToken: String
}
