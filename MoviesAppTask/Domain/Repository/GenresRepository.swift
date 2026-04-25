import Combine
import Foundation

// MARK: - GenresRepositoryProtocol

/// A protocol defining the contract for genre-related data operations.
///
/// Conforming types provide access to movie genres, abstracting away the
/// underlying data sources (network, persistence, etc.).
protocol GenresRepository {
    /// Fetches a list of movie genres.
    ///
    /// The returned publisher emits genres from the single source of truth
    /// (local persistence). When online, the cache is refreshed from the
    /// network before emission. When offline, cached data is returned directly.
    ///
    /// - Returns: A publisher emitting an array of `Genre`, or an `Error` if
    ///            both network and cache fail.
    func fetchMovieGenres() -> AnyPublisher<[Genre], Error>
}
