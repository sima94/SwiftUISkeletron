//
//  Register.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 27.5.25..
//

import Foundation
import NetworkRelay

struct RegisterRequest: HTTPRequest {
	var method: HTTPRequestMethod = .post
	var path: String = "api/v1/auth/register"
	var queryParameters: [URLQueryItem]?
	var body: Data?
	var headers: [HTTPRequestHeader]?
	var validResponseStatusCodes: Range<Int>? = 201 ..< 202

	init(registerUser: RegisterUser) throws {
		self.body = try JSONEncoder().encode(registerUser)
	}
}
