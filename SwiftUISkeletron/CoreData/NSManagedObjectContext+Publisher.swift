//
//  NSManagedObjectContext+Publisher.swift
//  SwiftUISkeletron
//

import CoreData
@preconcurrency import Combine

// MARK: - FetchedResultsPublisher

struct FetchedResultsPublisher<T: NSManagedObject>: Publisher {

	typealias Output = [T]
	typealias Failure = Never

	let fetchRequest: NSFetchRequest<T>
	let context: NSManagedObjectContext

	func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
		let subscription = FetchedResultsSubscription(
			subscriber: subscriber,
			fetchRequest: fetchRequest,
			context: context
		)
		subscriber.receive(subscription: subscription)
	}
}

// MARK: - FetchedResultsSubscription

private final class FetchedResultsSubscription<S: Subscriber, T: NSManagedObject>: NSObject,
	Subscription,
	NSFetchedResultsControllerDelegate
where S.Input == [T], S.Failure == Never {

	private var subscriber: S?
	private var fetchedResultsController: NSFetchedResultsController<T>?

	init(subscriber: S, fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext) {
		self.subscriber = subscriber
		super.init()

		let controller = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		controller.delegate = self
		self.fetchedResultsController = controller

		do {
			try controller.performFetch()
			_ = subscriber.receive(controller.fetchedObjects ?? [])
		} catch {
			_ = subscriber.receive([])
		}
	}

	func request(_ demand: Subscribers.Demand) {}

	func cancel() {
		fetchedResultsController?.delegate = nil
		fetchedResultsController = nil
		subscriber = nil
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
		guard let subscriber else { return }
		let objects = fetchedResultsController?.fetchedObjects ?? []
		_ = subscriber.receive(objects)
	}
}

// MARK: - NSManagedObjectContext Extensions

extension NSManagedObjectContext {

	func fetchedResultsPublisher<T: NSManagedObject>(
		for fetchRequest: NSFetchRequest<T>
	) -> FetchedResultsPublisher<T> {
		FetchedResultsPublisher(fetchRequest: fetchRequest, context: self)
	}

	func observe<T: NSManagedObject, M: Sendable>(
		_ fetchRequest: NSFetchRequest<T>,
		map transform: @escaping @Sendable (T) -> M
	) -> AsyncStream<[M]> {
		AsyncStream { continuation in
			let cancellable = self.fetchedResultsPublisher(for: fetchRequest)
				.map { entities in entities.map(transform) }
				.sink { continuation.yield($0) }

			continuation.onTermination = { @Sendable _ in
				cancellable.cancel()
			}
		}
	}
}
