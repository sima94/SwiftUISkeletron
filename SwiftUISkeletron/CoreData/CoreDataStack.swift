//
//  CoreDataStack.swift
//  SwiftUISkeletron
//

import CoreData
import Infuse

// MARK: - Dependency Key

struct CoreDataStackKey: DependencyKey {
	static var liveValue: CoreDataStack { CoreDataStack() }
	static var testValue: CoreDataStack { CoreDataStack(inMemory: true) }
}

// MARK: - CoreDataStack

final class CoreDataStack: Sendable {

	static let modelName = "SwiftUISkeletron"

	let persistentContainer: NSPersistentContainer

	var viewContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}

	init(inMemory: Bool = false) {
		persistentContainer = NSPersistentContainer(name: Self.modelName)

		if inMemory {
			let description = NSPersistentStoreDescription()
			description.type = NSInMemoryStoreType
			persistentContainer.persistentStoreDescriptions = [description]
		}

		persistentContainer.loadPersistentStores { description, error in
			if let error {
				fatalError("CoreData failed to load: \(error.localizedDescription)")
			}
		}

		persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
		persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
	}

	func newBackgroundContext() -> NSManagedObjectContext {
		let context = persistentContainer.newBackgroundContext()
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		return context
	}

	func save(context: NSManagedObjectContext? = nil) throws {
		let context = context ?? viewContext
		guard context.hasChanges else { return }
		try context.save()
	}
}
