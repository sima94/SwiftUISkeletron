//
//  Environment.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//


import Foundation
import NetworkRelay

protocol EnvironmentProtocol {

	var endpoint: Endpoint { get }
}
struct Environment: EnvironmentProtocol {

	let endpoint: Endpoint
}

extension Environment {
	static let `default` = Environment(
		endpoint: .init(
			scheme: "http",
			urlHost: "localhost",
			port: 8080,
		)
	)
}
