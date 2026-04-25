import Combine
import Foundation
import SwiftData

// MARK: - MovieRepositoryProtocol

/// Defines movie data operations for trending lists and movie details.
///
/// This repository is designed around a cache-first approach:
/// the UI always consumes locally cached data, while network responses
/// are used only to refresh that cache.
protocol MovieRepository {
    /// Fetches a paginated list of trending movies from cache.
    ///
    /// Behavior:
    /// 1. If the device is online, the repository requests fresh data from the API.
    /// 2. On success, it optionally clears old cached items.
    /// 3. It saves the fresh response into local storage.
    /// 4. It then reads the requested page from local cache and returns it.
    /// 5. If offline or if the request fails, it falls back to cached data.
    ///
    /// - Parameters:
    ///   - pageSize: The number of items to return per page.
    ///   - page: The one-based page index expected by the API.
    ///   - shouldResetCache: When `true`, clears previously cached trending movies
    ///     only after a successful API response. This is useful for refresh flows.
    /// - Returns: A publisher emitting a paginated list of domain `Movie` values.
    func fetchTrendingMovies(
        pageSize: Int,
        page: Int,
        shouldResetCache: Bool
    ) -> AnyPublisher<PaginatedModel<Movie>, Error>

    /// Fetches movie details from cache.
    ///
    /// Behavior:
    /// 1. If online, fetch the latest details from the API.
    /// 2. Save genres and detailed movie data into local storage.
    /// 3. Read the saved result back from cache and return it.
    /// 4. If offline or if the request fails, return cached details instead.
    ///
    /// - Parameter id: The unique movie identifier.
    /// - Returns: A publisher emitting a fully mapped `MovieDetail`.
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetail, Error>
}
