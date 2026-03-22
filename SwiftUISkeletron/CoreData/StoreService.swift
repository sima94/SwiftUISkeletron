//
//  StoreService.swift
//  SwiftUISkeletron
//

@preconcurrency import CoreData

final class StoreService<Model: Storable>: @unchecked Sendable {

	let coreData: CoreDataStack

	init(coreData: CoreDataStack) {
		self.coreData = coreData
	}

	// MARK: - Observe

	func observe(_ request: NSFetchRequest<Model.Entity>? = nil) -> AsyncStream<[Model]> {
		let transform: @Sendable (Model.Entity) -> Model = { entity in Model(from: entity) }
		return coreData.viewContext.observe(request ?? makeFetchRequest(), map: transform)
	}

	// MARK: - Fetch

	func fetchAll(_ request: NSFetchRequest<Model.Entity>? = nil) async throws -> [Model] {
		let context = coreData.viewContext
		let fetchRequest = request ?? makeFetchRequest()
		return try await context.perform {
			try context.fetch(fetchRequest).map { Model(from: $0) }
		}
	}

	// MARK: - Save

	func save(_ items: [Model]) async throws {
		let context = coreData.newBackgroundContext()
		let name = Model.entityName
		try await context.perform {
			for item in items {
				let entity = NSEntityDescription.insertNewObject(forEntityName: name, into: context) as! Model.Entity
				item.configure(entity)
			}
			try context.save()
		}
	}

	// MARK: - Delete

	func deleteAll() async throws {
		let context = coreData.newBackgroundContext()
		let name = Model.entityName
		try await context.perform {
			let request = NSFetchRequest<NSManagedObject>(entityName: name)
			let objects = try context.fetch(request)
			for object in objects {
				context.delete(object)
			}
			try context.save()
		}
	}

	// MARK: - Helpers

	private func makeFetchRequest() -> NSFetchRequest<Model.Entity> {
		let request = NSFetchRequest<Model.Entity>(entityName: Model.entityName)
		request.sortDescriptors = Model.defaultSortDescriptors
		return request
	}
}
