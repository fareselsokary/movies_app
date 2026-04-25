import Combine
import Foundation
import SwiftData

// MARK: - PersistenceDeleting

/// Defines the interface for removing entities from a SwiftData store.
protocol PersistenceDeleting {
    associatedtype Entity: PersistentModel

    /// Removes all persisted entities of the associated type and commits the deletion.
    func deleteAll() -> AnyPublisher<Void, Error>
}
