//
//  HomeRepository.swift
//  SwiftUISkeletron
//

import Foundation
import Infuse

// MARK: - Dependency Key

struct HomeRepositoryKey: DependencyKey {
	static var liveValue: any HomeRepositoryProtocol { HomeRepository() }
	static var testValue: any HomeRepositoryProtocol { MockHomeRepository() }
}

// MARK: - HomeRepository

final class HomeRepository: HomeRepositoryProtocol {

	private let network: any HomeNetworkServiceProtocol
	private let store: any HomeStoreServiceProtocol

	init() {
		@Dependency(HomeNetworkServiceKey.self) var network
		@Dependency(HomeStoreServiceKey.self) var store
		self.network = network
		self.store = store
	}

	func observe() -> AsyncStream<[HomeListData]> {
		store.observe()
	}

	func refresh() async throws {
		let remote = try await network.fetchHomeListData()
		try await store.deleteAll()
		try await store.save(remote)
	}

	func getDetail(id: Int) async throws -> HomeDetailData {
		try await network.fetchHomeDetailData(id: id)
	}
}

// MARK: - Mock

final class MockHomeRepository: HomeRepositoryProtocol {
	func observe() -> AsyncStream<[HomeListData]> {
		AsyncStream { $0.yield([]); $0.finish() }
	}
	func refresh() async throws {}
	func getDetail(id: Int) async throws -> HomeDetailData {
		HomeDetailData(title: "Mock", subtitle: "Mock", description: "Mock")
	}
}
