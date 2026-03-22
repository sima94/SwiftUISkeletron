//
//  HomeRepositoryProtocol.swift
//  SwiftUISkeletron
//

import Foundation

protocol HomeRepositoryProtocol: Sendable {
	func observe() -> AsyncStream<[HomeListData]>
	func refresh() async throws
	func getDetail(id: Int) async throws -> HomeDetailData
}
