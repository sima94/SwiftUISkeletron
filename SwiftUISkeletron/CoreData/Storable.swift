//
//  Storable.swift
//  SwiftUISkeletron
//

import CoreData

protocol Storable: Sendable {
	associatedtype Entity: NSManagedObject
	static var entityName: String { get }
	static var defaultSortDescriptors: [NSSortDescriptor] { get }
	init(from entity: Entity)
	func configure(_ entity: Entity)
}

extension Storable {
	static var entityName: String { String(describing: Entity.self) }
	static var defaultSortDescriptors: [NSSortDescriptor] { [] }
}
