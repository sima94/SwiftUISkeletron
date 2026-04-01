//
//  HomeStoreService.swift
//  SwiftUISkeletron
//

import CoreData
import Infuse

// MARK: - Dependency Key

struct HomeStoreServiceKey: DependencyKey {
	static var liveValue: any HomeStoreServiceProtocol {
		@Dependency(\.coreDataStack) var coreData
		return StoreService<HomeListData>(coreData: coreData)
	}
	static var testValue: any HomeStoreServiceProtocol {
		MockHomeStoreService()
	}
}

extension DependencyValues {
	var homeStoreService: any HomeStoreServiceProtocol {
		get { self[HomeStoreServiceKey.self] }
		set { self[HomeStoreServiceKey.self] = newValue }
	}
}

// MARK: - StoreService conformance

extension StoreService: HomeStoreServiceProtocol where Model == HomeListData {}

// MARK: - Mock

final class MockHomeStoreService: HomeStoreServiceProtocol {
	func observe(_ request: NSFetchRequest<HomeEntity>?) -> AsyncStream<[HomeListData]> {
		AsyncStream { $0.yield([]); $0.finish() }
	}
	func fetchAll(_ request: NSFetchRequest<HomeEntity>?) async throws -> [HomeListData] { [] }
	func save(_ items: [HomeListData]) async throws {}
	func deleteAll() async throws {}
}
