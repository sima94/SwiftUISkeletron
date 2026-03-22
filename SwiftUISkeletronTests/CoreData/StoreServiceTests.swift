//
//  StoreServiceTests.swift
//  SwiftUISkeletronTests
//

import Testing
import CoreData
@testable import SwiftUISkeletron

// MARK: - StoreService Tests

@Suite("StoreService")
struct StoreServiceTests {

	private func makeStore() -> StoreService<HomeListData> {
		let stack = CoreDataStack(inMemory: true)
		return StoreService<HomeListData>(coreData: stack)
	}

	// MARK: - Save & Fetch

	@Test("Save and fetchAll returns saved items")
	func saveAndFetch() async throws {
		let store = makeStore()
		let items = [
			HomeListData(title: "Alpha"),
			HomeListData(title: "Beta"),
			HomeListData(title: "Charlie"),
		]

		try await store.save(items)

		try await Task.sleep(nanoseconds: 100_000_000)

		let fetched = try await store.fetchAll()
		#expect(fetched.count == 3)
		#expect(fetched.map(\.title) == ["Alpha", "Beta", "Charlie"])
	}

	@Test("FetchAll on empty store returns empty array")
	func fetchAllEmpty() async throws {
		let store = makeStore()
		let fetched = try await store.fetchAll()
		#expect(fetched.isEmpty)
	}

	@Test("Save preserves id and title")
	func savePreservesFields() async throws {
		let store = makeStore()
		let id = UUID()
		let item = HomeListData(id: id, title: "Test")

		try await store.save([item])
		try await Task.sleep(nanoseconds: 100_000_000)

		let fetched = try await store.fetchAll()
		#expect(fetched.count == 1)
		#expect(fetched.first?.id == id)
		#expect(fetched.first?.title == "Test")
	}

	// MARK: - Delete

	@Test("DeleteAll removes all items")
	func deleteAll() async throws {
		let store = makeStore()
		try await store.save([
			HomeListData(title: "One"),
			HomeListData(title: "Two"),
		])
		try await Task.sleep(nanoseconds: 100_000_000)

		try await store.deleteAll()
		try await Task.sleep(nanoseconds: 100_000_000)

		let fetched = try await store.fetchAll()
		#expect(fetched.isEmpty)
	}

	@Test("DeleteAll on empty store does not throw")
	func deleteAllEmpty() async throws {
		let store = makeStore()
		try await store.deleteAll()
	}

	// MARK: - Observe

	@Test("Observe emits initial empty array")
	@MainActor
	func observeInitialEmpty() async throws {
		let store = makeStore()

		try await confirmation { confirm in
			let task = Task {
				for await items in store.observe() {
					#expect(items.isEmpty)
					confirm()
					break
				}
			}

			try await Task.sleep(nanoseconds: 500_000_000)
			task.cancel()
		}
	}

	@Test("Observe emits update after save")
	@MainActor
	func observeEmitsAfterSave() async throws {
		let store = makeStore()

		try await confirmation(expectedCount: 2) { confirm in
			let task = Task {
				for await items in store.observe() {
					confirm()
					if !items.isEmpty {
						#expect(items.count == 1)
						#expect(items.first?.title == "New")
					}
				}
			}

			// Wait for initial emission
			try await Task.sleep(nanoseconds: 100_000_000)

			try await store.save([HomeListData(title: "New")])

			try await Task.sleep(nanoseconds: 1_000_000_000)
			task.cancel()
		}
	}

	// MARK: - Sort Order

	@Test("FetchAll returns items sorted by defaultSortDescriptors")
	func fetchAllSorted() async throws {
		let store = makeStore()
		try await store.save([
			HomeListData(title: "Zebra"),
			HomeListData(title: "Apple"),
			HomeListData(title: "Mango"),
		])
		try await Task.sleep(nanoseconds: 100_000_000)

		let fetched = try await store.fetchAll()
		#expect(fetched.map(\.title) == ["Apple", "Mango", "Zebra"])
	}

	// MARK: - Multiple Operations

	@Test("Save, delete, save produces correct state")
	func saveDeleteSave() async throws {
		let store = makeStore()

		try await store.save([HomeListData(title: "First")])
		try await Task.sleep(nanoseconds: 100_000_000)

		try await store.deleteAll()
		try await Task.sleep(nanoseconds: 100_000_000)

		try await store.save([HomeListData(title: "Second")])
		try await Task.sleep(nanoseconds: 100_000_000)

		let fetched = try await store.fetchAll()
		#expect(fetched.count == 1)
		#expect(fetched.first?.title == "Second")
	}
}

// MARK: - Storable Protocol Tests

@Suite("Storable Protocol")
struct StorableProtocolTests {

	@Test("HomeListData entityName is HomeEntity")
	func entityName() {
		#expect(HomeListData.entityName == "HomeEntity")
	}

	@Test("HomeListData has sort descriptors")
	func sortDescriptors() {
		let sorts = HomeListData.defaultSortDescriptors
		#expect(sorts.count == 1)
		#expect(sorts.first?.key == "title")
		#expect(sorts.first?.ascending == true)
	}

	@Test("Storable init and configure round-trip")
	func roundTrip() {
		let stack = CoreDataStack(inMemory: true)
		let context = stack.viewContext
		let entity = HomeEntity(context: context)

		let original = HomeListData(id: UUID(), title: "Round Trip")
		original.configure(entity)

		let restored = HomeListData(from: entity)
		#expect(restored.id == original.id)
		#expect(restored.title == original.title)
	}
}
