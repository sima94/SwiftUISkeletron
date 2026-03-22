//
//  HomeNetworkServiceProtocol.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import Foundation

protocol HomeNetworkServiceProtocol: Sendable {
	func fetchHomeListData() async throws -> [HomeListData]
	func fetchHomeDetailData(id: Int) async throws -> HomeDetailData
}
