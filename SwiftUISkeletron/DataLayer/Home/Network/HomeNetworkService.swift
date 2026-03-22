//
//  HomeNetworkService.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import Foundation
import Infuse
import NetworkRelay

// MARK: - Dependency Key

struct HomeNetworkServiceKey: DependencyKey {
	static var liveValue: any HomeNetworkServiceProtocol {
		@Dependency(NetworkServiceKey.self) var network
		return HomeNetworkService(networkService: network)
	}
	static var testValue: any HomeNetworkServiceProtocol {
		MockHomeNetworkService()
	}
}

// MARK: - HomeNetworkService

final class HomeNetworkService: HomeNetworkServiceProtocol, Sendable {

	let networkService: any NetworkingServiceProtocol

	init(networkService: any NetworkingServiceProtocol) {
		self.networkService = networkService
	}

	func fetchHomeListData() async throws -> [HomeListData] {
		return [.init(title: "Test1"), .init(title: "Test2"), .init(title: "Test3")]
		//return try await networkService.fetchRequest(HomeFetchRequest())
	}

	func fetchHomeDetailData(id: Int) async throws -> HomeDetailData {
		return HomeDetailData(id: .init(), title: "Title", subtitle: "Subtitle", description: "Description")
	}
}

// MARK: - Mock

final class MockHomeNetworkService: HomeNetworkServiceProtocol, Sendable {
	func fetchHomeListData() async throws -> [HomeListData] { [] }
	func fetchHomeDetailData(id: Int) async throws -> HomeDetailData {
		HomeDetailData(title: "Mock", subtitle: "Mock", description: "Mock")
	}
}
