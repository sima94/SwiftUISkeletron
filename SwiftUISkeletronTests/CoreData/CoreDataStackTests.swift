//
//  CoreDataStackTests.swift
//  SwiftUISkeletronTests
//

import Testing
import CoreData
@testable import SwiftUISkeletron

// MARK: - Helpers

private func makeInMemoryContainer() -> NSPersistentContainer {
	let model = NSManagedObjectModel()

	let entity = NSEntityDescription()
	entity.name = "TestEntity"
	entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

	let nameAttribute = NSAttributeDescription()
	nameAttribute.name = "name"
	nameAttribute.attributeType = .stringAttributeType
	nameAttribute.isOptional = true
	entity.properties = [nameAttribute]

	model.entities = [entity]

	let container = NSPersistentContainer(name: "TestStore", managedObjectModel: model)
	let description = NSPersistentStoreDescription()
	description.type = NSInMemoryStoreType
	container.persistentStoreDescriptions = [description]
	container.loadPersistentStores { _, error in
		if let error { fatalError("Failed to load test store: \(error)") }
	}
	container.viewContext.automaticallyMergesChangesFromParent = true
	container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
	return container
}

private func insertTestEntity(name: String, in context: NSManagedObjectContext) -> NSManagedObject {
	let entity = NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context)
	entity.setValue(name, forKey: "name")
	return entity
}

private func makeFetchRequest() -> NSFetchRequest<NSManagedObject> {
	let request = NSFetchRequest<NSManagedObject>(entityName: "TestEntity")
	request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
	return request
}

// MARK: - CoreDataStack Tests

@Suite("CoreDataStack")
struct CoreDataStackTests {

	@Test("In-memory stack creates without crash")
	func inMemoryInit() {
		let stack = CoreDataStack(inMemory: true)
		#expect(stack.persistentContainer.persistentStoreDescriptions.first?.type == NSInMemoryStoreType)
	}

	@Test("viewContext is main queue context")
	func viewContextIsMain() {
		let stack = CoreDataStack(inMemory: true)
		#expect(stack.viewContext.concurrencyType == .mainQueueConcurrencyType)
	}

	@Test("viewContext auto-merges from parent")
	func viewContextAutoMerge() {
		let stack = CoreDataStack(inMemory: true)
		#expect(stack.viewContext.automaticallyMergesChangesFromParent == true)
	}

	@Test("newBackgroundContext returns private queue context")
	func backgroundContextType() {
		let stack = CoreDataStack(inMemory: true)
		let bg = stack.newBackgroundContext()
		#expect(bg.concurrencyType == .privateQueueConcurrencyType)
	}

	@Test("save does nothing when no changes")
	func saveNoChanges() throws {
		let stack = CoreDataStack(inMemory: true)
		try stack.save()
	}
}

// MARK: - CoreDataStack Save Tests (with programmatic model)

@Suite("CoreDataStack Save")
struct CoreDataStackSaveTests {

	@Test("save persists object in viewContext")
	func saveViewContext() throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext

		_ = insertTestEntity(name: "Test", in: context)
		try context.save()

		let request = makeFetchRequest()
		let results = try context.fetch(request)
		#expect(results.count == 1)
		#expect(results.first?.value(forKey: "name") as? String == "Test")
	}

	@Test("background save merges into viewContext")
	func backgroundSaveMergesIntoMain() async throws {
		let container = makeInMemoryContainer()
		let bgContext = container.newBackgroundContext()
		bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

		try await bgContext.perform {
			_ = insertTestEntity(name: "Background", in: bgContext)
			try bgContext.save()
		}

		try await Task.sleep(nanoseconds: 100_000_000)

		let request = makeFetchRequest()
		let results = try container.viewContext.fetch(request)
		#expect(results.count == 1)
		#expect(results.first?.value(forKey: "name") as? String == "Background")
	}

	@Test("delete removes object")
	func deleteObject() throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext

		let obj = insertTestEntity(name: "ToDelete", in: context)
		try context.save()

		context.delete(obj)
		try context.save()

		let request = makeFetchRequest()
		let results = try context.fetch(request)
		#expect(results.isEmpty)
	}
}
