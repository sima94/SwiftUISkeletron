//
//  HomeListData.swift
//  SwiftUISkeletron
//

import Foundation
import CoreData

struct HomeListData: Identifiable, Hashable, Codable, Sendable, Storable {

	typealias Entity = HomeEntity

	var id = UUID()
	var title: String

	// MARK: - Storable

	static var defaultSortDescriptors: [NSSortDescriptor] {
		[NSSortDescriptor(key: "title", ascending: true)]
	}

	init(from entity: HomeEntity) {
		self.id = entity.id ?? UUID()
		self.title = entity.title ?? ""
	}

	func configure(_ entity: HomeEntity) {
		entity.id = id
		entity.title = title
	}

	// MARK: - Standard init

	init(id: UUID = UUID(), title: String) {
		self.id = id
		self.title = title
	}
}
