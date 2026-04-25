import Combine
import Foundation
import SwiftData

// MARK: - PersistenceManager

/// A thread-safe, generic persistence manager built on SwiftData and Combine.
///
/// Each instance manages its own `ModelContext` and runs all operations on a
/// private serial queue. Results are delivered via Combine publishers.
final class PersistenceManager<T: PersistentModel>
    where T: Identifiable, T.ID: Codable & Hashable {
    typealias Entity = T

    // MARK: - Properties

    /// The SwiftData container backing this manager.
    private let container: ModelContainer

    /// Serial queue that serializes all context access.
    private let queue = DispatchQueue(label: "PersistenceManager.queue")

    /// The context used for all read/write operations. Only accessed on `queue`.
    private lazy var context: ModelContext = {
        ModelContext(container)
    }()

    // MARK: - Init

    /// Creates a new persistence manager.
    ///
    /// - Parameter container: The container to use. Defaults to the app's shared container.
    init(container: ModelContainer) {
        self.container = container
    }
}

// MARK: - Private Executor

private extension PersistenceManager {
    /// Runs a block on the internal queue and wraps the result in a publisher.
    ///
    /// - Parameter work: Closure that receives the `ModelContext` and returns a value.
    /// - Returns: A publisher that emits the result or an error.
    func perform<R>(
        _ work: @escaping (ModelContext) throws -> R
    ) -> AnyPublisher<R, Error> {
        Deferred {
            Future { promise in
                self.queue.async {
                    do {
                        let result = try work(self.context)
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - PersistenceWriting

extension PersistenceManager {
    /// Inserts and saves a single entity.
    func save(_ entity: T) -> AnyPublisher<Void, Error> {
        perform { context in
            context.insert(entity)
            try context.save()
        }
    }

    /// Inserts and saves multiple entities in a single transaction.
    func save(_ entities: [T]) -> AnyPublisher<Void, Error> {
        perform { context in
            entities.forEach { context.insert($0) }
            try context.save()
        }
    }
}

// MARK: - PersistenceFetching

extension PersistenceManager {
    /// Fetches entities with optional filtering, sorting, and pagination.
    ///
    /// - Parameters:
    ///   - predicate: Optional filter applied to the query.
    ///   - sort: Sort descriptors applied to the results.
    ///   - pageSize: Number of items per page. Pass `nil` to fetch all results.
    ///   - page: Zero-based page index. Pass `nil` to fetch all results.
    /// - Returns: A publisher emitting the paginated results.
    func fetch(
        where predicate: Predicate<T>? = nil,
        sortedBy sort: [SortDescriptor<T>] = [],
        pageSize: Int? = nil,
        page: Int? = nil
    ) -> AnyPublisher<CachedPaginatedEntity<Entity>, Error> {
        perform { context in
            let descriptor = FetchDescriptor(predicate: predicate, sortBy: sort)
            return try self.fetchModels(
                context: context,
                descriptor: descriptor,
                pageSize: pageSize,
                page: page
            )
        }
    }

    /// Fetches a single entity by its identifier.
    ///
    /// - Parameter id: The entity's ID.
    /// - Returns: A publisher emitting the entity, or an error if not found.
    func fetch(byID id: T.ID) -> AnyPublisher<T, Error> {
        perform { context in
            let descriptor = FetchDescriptor<T>(
                predicate: #Predicate { $0.id == id }
            )

            let results = try context.fetch(descriptor)

            guard let entity = results.first else {
                throw NSError(
                    domain: "PersistenceManager",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Entity not found."]
                )
            }

            return entity
        }
    }

    func fetch(byIDs ids: [T.ID]) -> AnyPublisher<[T], Error> {
        perform { context in
            let descriptor = FetchDescriptor<T>(
                predicate: #Predicate { ids.contains($0.id) }
            )
            return try context.fetch(descriptor)
        }
    }
}

// MARK: - PersistenceDeleting

extension PersistenceManager {
    /// Deletes all entities of type `T` from the store.
    func deleteAll() -> AnyPublisher<Void, Error> {
        perform { context in
            let all = try context.fetch(FetchDescriptor<T>())
            all.forEach { context.delete($0) }
            try context.save()
        }
    }
}

// MARK: - Helpers

private extension PersistenceManager {
    /// Performs a fetch with pagination metadata.
    ///
    /// Applies `fetchLimit` and `fetchOffset` when both `pageSize` and `page`
    /// are provided, and computes the total page count from the full result set.
    func fetchModels(
        context: ModelContext,
        descriptor: FetchDescriptor<T>,
        pageSize: Int?,
        page: Int?
    ) throws -> CachedPaginatedEntity<Entity> {
        let countDescriptor = descriptor

        var paginatedDescriptor = descriptor

        if let page = page, let pageSize = pageSize {
            paginatedDescriptor.fetchLimit = pageSize
            paginatedDescriptor.fetchOffset = page * pageSize
        }

        let results = try context.fetch(paginatedDescriptor)
        let totalCount = try context.fetchCount(countDescriptor)

        let effectivePageSize = pageSize ?? totalCount

        let totalPages = effectivePageSize > 0
            ? (totalCount + effectivePageSize - 1) / effectivePageSize
            : 1

        return CachedPaginatedEntity(
            page: page ?? 0,
            results: results,
            totalPages: totalPages,
            totalResults: totalCount
        )
    }
}
