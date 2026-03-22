//
//  HomeRequest.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import Foundation
import NetworkRelay

struct HomeListFetchRequest: HTTPFetchRequest {
	typealias Object = [HomeListData]
	var decoder: JSONDecoder = .init()
	var method: HTTPRequestMethod = .get
	var path: String = "api/v1/home"
	var queryParameters: [URLQueryItem]?
	var body: Data?
	var headers: [HTTPRequestHeader]?
	var validResponseStatusCodes: Range<Int>? = 200..<201
}
