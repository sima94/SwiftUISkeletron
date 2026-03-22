//
//  AuthenticationService.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 27.5.25..
//

import Foundation

protocol AuthenticationServiceProtocol: Sendable {
	func registerUser(_ user: RegisterUser) async throws
	func loginUser(username: String, password: String) async throws 
}
