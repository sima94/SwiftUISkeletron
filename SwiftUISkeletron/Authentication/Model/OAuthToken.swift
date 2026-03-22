//
//  OAuthToken.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 27.5.25..
//

import Foundation

struct OAuthToken: Codable, Hashable, Sendable {
	let accessToken: String
	let refreshToken: String
}
