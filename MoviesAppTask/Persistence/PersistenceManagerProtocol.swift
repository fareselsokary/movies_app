import SwiftData

// MARK: - PersistenceManagerProtocol

/// Combines all persistence capabilities (`PersistenceWriting`, `PersistenceFetching`,
/// `PersistenceDeleting`) into a single constraint.
///
/// Prefer constraining to individual protocols when only a subset is needed.
typealias PersistenceManagerProtocol = PersistenceWriting & PersistenceFetching & PersistenceDeleting
