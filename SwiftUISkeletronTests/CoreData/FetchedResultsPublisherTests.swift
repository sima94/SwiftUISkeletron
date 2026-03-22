//
//  FetchedResultsPublisherTests.swift
//  SwiftUISkeletronTests
//

import Testing
import CoreData
import Combine
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

private func makeFetchRequest() -> NSFetchRequest<NSManagedObject> {
	let request = NSFetchRequest<NSManagedObject>(entityName: "TestEntity")
	request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
	return request
}

// MARK: - FetchedResultsPublisher Tests

@Suite("FetchedResultsPublisher")
struct FetchedResultsPublisherTests {

	@Test("Emits initial empty array")
	@MainActor
	func initialEmptyFetch() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext
		let request = makeFetchRequest()

		try await confirmation { confirm in
			var cancellables = Set<AnyCancellable>()

			context.fetchedResultsPublisher(for: request)
				.sink { objects in
					#expect(objects.isEmpty)
					confirm()
				}
				.store(in: &cancellables)

			try await Task.sleep(nanoseconds: 500_000_000)
			_ = cancellables
		}
	}

	@Test("Emits initial data when objects exist")
	@MainActor
	func initialDataFetch() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext

		NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context)
			.setValue("Existing", forKey: "name")
		try context.save()

		try await confirmation { confirm in
			var cancellables = Set<AnyCancellable>()
			let request = makeFetchRequest()

			context.fetchedResultsPublisher(for: request)
				.sink { objects in
					if objects.count == 1 {
						confirm()
					}
				}
				.store(in: &cancellables)

			try await Task.sleep(nanoseconds: 500_000_000)
			_ = cancellables
		}
	}

	@Test("Emits update when object is inserted")
	@MainActor
	func insertTriggersUpdate() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext
		let request = makeFetchRequest()

		try await confirmation(expectedCount: 2) { confirm in
			var cancellables = Set<AnyCancellable>()

			context.fetchedResultsPublisher(for: request)
				.sink { _ in
					confirm()
				}
				.store(in: &cancellables)

			try await Task.sleep(nanoseconds: 50_000_000)

			NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context)
				.setValue("New", forKey: "name")
			try context.save()

			try await Task.sleep(nanoseconds: 500_000_000)
			_ = cancellables
		}
	}

	@Test("Emits update when object is deleted")
	@MainActor
	func deleteTriggersUpdate() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext

		let obj = NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context)
		obj.setValue("ToDelete", forKey: "name")
		try context.save()

		try await confirmation(expectedCount: 2) { confirm in
			var cancellables = Set<AnyCancellable>()
			let request = makeFetchRequest()

			context.fetchedResultsPublisher(for: request)
				.sink { _ in
					confirm()
				}
				.store(in: &cancellables)

			try await Task.sleep(nanoseconds: 50_000_000)

			context.delete(obj)
			try context.save()

			try await Task.sleep(nanoseconds: 500_000_000)
			_ = cancellables
		}
	}

	@Test("Cancel stops receiving updates")
	@MainActor
	func cancelStopsUpdates() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext
		let request = makeFetchRequest()

		// Expect exactly 1 emission (the initial), not 2
		try await confirmation(expectedCount: 1) { confirm in
			var cancellable: AnyCancellable?

			cancellable = context.fetchedResultsPublisher(for: request)
				.sink { _ in
					confirm()
				}

			try await Task.sleep(nanoseconds: 50_000_000)
			cancellable?.cancel()
			cancellable = nil

			NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context)
				.setValue("AfterCancel", forKey: "name")
			try context.save()

			try await Task.sleep(nanoseconds: 500_000_000)
		}
	}

	@Test("Background save triggers publisher on viewContext")
	@MainActor
	func backgroundSaveTriggersPublisher() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext
		let request = makeFetchRequest()

		try await confirmation(expectedCount: 2) { confirm in
			var cancellables = Set<AnyCancellable>()

			context.fetchedResultsPublisher(for: request)
				.sink { _ in
					confirm()
				}
				.store(in: &cancellables)

			try await Task.sleep(nanoseconds: 50_000_000)

			let bgContext = container.newBackgroundContext()
			bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
			try await bgContext.perform {
				NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: bgContext)
					.setValue("FromBackground", forKey: "name")
				try bgContext.save()
			}

			try await Task.sleep(nanoseconds: 500_000_000)
			_ = cancellables
		}
	}
}

// MARK: - observe(_:map:) Tests

@Suite("NSManagedObjectContext.observe")
struct ObserveExtensionTests {

	@Test("Emits initial mapped values")
	@MainActor
	func initialMappedValues() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext

		NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context)
			.setValue("Alpha", forKey: "name")
		NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context)
			.setValue("Beta", forKey: "name")
		try context.save()

		let request = makeFetchRequest()

		try await confirmation { confirm in
			let task = Task {
				for await names in context.observe(request, map: { ($0.value(forKey: "name") as? String) ?? "" }) {
					#expect(names == ["Alpha", "Beta"])
					confirm()
					break
				}
			}

			try await Task.sleep(nanoseconds: 500_000_000)
			task.cancel()
		}
	}

	@Test("Emits empty array when no data")
	@MainActor
	func emptyMappedValues() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext
		let request = makeFetchRequest()

		try await confirmation { confirm in
			let task = Task {
				for await names in context.observe(request, map: { ($0.value(forKey: "name") as? String) ?? "" }) {
					#expect(names.isEmpty)
					confirm()
					break
				}
			}

			try await Task.sleep(nanoseconds: 500_000_000)
			task.cancel()
		}
	}

	@Test("Insert triggers mapped update")
	@MainActor
	func insertTriggersMappedUpdate() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext
		let request = makeFetchRequest()

		try await confirmation(expectedCount: 2) { confirm in
			let task = Task {
				for await _ in context.observe(request, map: { ($0.value(forKey: "name") as? String) ?? "" }) {
					confirm()
				}
			}

			try await Task.sleep(nanoseconds: 50_000_000)

			NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context)
				.setValue("NewItem", forKey: "name")
			try context.save()

			try await Task.sleep(nanoseconds: 500_000_000)
			task.cancel()
		}
	}

	@Test("Task cancellation stops stream")
	@MainActor
	func cancellationStopsStream() async throws {
		let container = makeInMemoryContainer()
		let context = container.viewContext
		let request = makeFetchRequest()

		// Expect exactly 1 emission (initial), not 2
		try await confirmation(expectedCount: 1) { confirm in
			let task = Task {
				for await _ in context.observe(request, map: { ($0.value(forKey: "name") as? String) ?? "" }) {
					confirm()
				}
			}

			try await Task.sleep(nanoseconds: 50_000_000)
			task.cancel()
			try await Task.sleep(nanoseconds: 50_000_000)

			NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: context)
				.setValue("AfterCancel", forKey: "name")
			try context.save()

			try await Task.sleep(nanoseconds: 500_000_000)
		}
	}
}
