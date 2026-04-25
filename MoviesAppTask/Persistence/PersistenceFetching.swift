import Combine
import Foundation
import SwiftData

// MARK: - PersistenceFetching

/// Defines the interface for querying entities from a SwiftData store.
protocol PersistenceFetching {
    associatedtype Entity: PersistentModel

    /// Fetches entities matching an optional predicate with sorting and pagination support.
    func fetch(
        where predicate: Predicate<Entity>?,
        sortedBy sort: [SortDescriptor<Entity>],
        pageSize: Int?,
        page: Int?
    ) -> AnyPublisher<CachedPaginatedEntity<Entity>, Error>

    /// Fetches a single entity by its identifier.
    func fetch(byID id: Entity.ID) -> AnyPublisher<Entity, Error>

    /// Fetches entities matching a list of identifiers.
    func fetch(byIDs ids: [Entity.ID]) -> AnyPublisher<[Entity], Error>
}
