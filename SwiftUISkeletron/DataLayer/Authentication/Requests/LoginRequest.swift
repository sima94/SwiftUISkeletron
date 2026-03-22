//
//  LoginRequest.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 27.5.25..
//

import Foundation
import NetworkRelay

struct LoginRequest: HTTPFetchRequest {
	typealias Object = LoginResponse
	var decoder: JSONDecoder = JSONDecoder()
	var method: HTTPRequestMethod = .post
	var path: String = "api/v1/auth/login"
	var queryParameters: [URLQueryItem]?
	var body: Data?
	var headers: [HTTPRequestHeader]?
	var validResponseStatusCodes: Range<Int>? = 200 ..< 201

	init(loginUser: LoginUser) throws {
		self.body = try JSONEncoder().encode(loginUser)
	}
}
