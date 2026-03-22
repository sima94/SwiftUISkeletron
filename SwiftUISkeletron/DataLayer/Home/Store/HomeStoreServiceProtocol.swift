//
//  HomeStoreServiceProtocol.swift
//  SwiftUISkeletron
//

import CoreData

protocol HomeStoreServiceProtocol: Sendable {
	func observe(_ request: NSFetchRequest<HomeEntity>?) -> AsyncStream<[HomeListData]>
	func fetchAll(_ request: NSFetchRequest<HomeEntity>?) async throws -> [HomeListData]
	func save(_ items: [HomeListData]) async throws
	func deleteAll() async throws
}

extension HomeStoreServiceProtocol {
	func observe() -> AsyncStream<[HomeListData]> { observe(nil) }
	func fetchAll() async throws -> [HomeListData] { try await fetchAll(nil) }
}
