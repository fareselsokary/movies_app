import Combine
import Foundation
import SwiftData

// MARK: - PersistenceSaving

/// Defines the interface for inserting entities into a SwiftData store.
protocol PersistenceWriting {
    associatedtype Entity: PersistentModel

    /// Inserts a single entity and commits the transaction.
    func save(_ entity: Entity) -> AnyPublisher<Void, Error>

    /// Inserts multiple entities and commits as a single batch.
    func save(_ entities: [Entity]) -> AnyPublisher<Void, Error>
}
