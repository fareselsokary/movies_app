import Combine
import Foundation
import SwiftData

// MARK: - MovieRepositoryImpl

/// Cache-first implementation of `MovieRepositoryProtocol`.
///
/// The repository never exposes raw API results directly to the UI.
/// Instead, remote responses are persisted first, and the UI receives
/// values that are read back from local cache. This keeps online and
/// offline behavior consistent and predictable.
final class MovieRepositoryImpl: MovieRepository {
    private let apiService: NetworkServiceProtocol
    private let moviePersistenceManager: PersistenceManager<CachedMovieEntity>
    private let genrePersistenceManager: PersistenceManager<CachedGenreEntity>
    private let networkReachability: NetworkReachabilityProtocol

    /// Creates a repository with its network, persistence, and reachability dependencies.
    ///
    /// - Parameters:
    ///   - apiService: Performs remote API requests.
    ///   - moviePersistenceManager: Reads and writes cached movie entities.
    ///   - genrePersistenceManager: Reads and writes cached genre entities.
    ///   - networkReachability: Reports whether the device is currently online.
    init(
        apiService: NetworkServiceProtocol,
        moviePersistenceManager: PersistenceManager<CachedMovieEntity>,
        genrePersistenceManager: PersistenceManager<CachedGenreEntity>,
        networkReachability: NetworkReachabilityProtocol
    ) {
        self.apiService = apiService
        self.moviePersistenceManager = moviePersistenceManager
        self.genrePersistenceManager = genrePersistenceManager
        self.networkReachability = networkReachability
    }

    /// Returns a page of trending movies while treating cache as the UI-facing source of truth.
    ///
    /// If the device is offline, this method skips the API and serves cached data.
    /// If online, it refreshes the cache from the API, then returns the cached page.
    /// When `shouldResetCache` is enabled, old cached movies are cleared only after
    /// the API request succeeds so that existing offline data is preserved on failures.
    func fetchTrendingMovies(
        pageSize: Int,
        page: Int,
        shouldResetCache: Bool = false
    ) -> AnyPublisher<PaginatedModel<Movie>, Error> {
        let localPage = max(page - 1, 0)
        let fallbackCachedPage = fetchTrendingMoviesFromCache(
            pageSize: pageSize,
            page: localPage
        )

        guard networkReachability.isConnected else {
            Logger.verbose("Offline: returning trending movies from cache.")
            return fallbackCachedPage
        }

        return fetchTrendingMoviesFromAPI(page: page)
            .flatMap { [weak self] response -> AnyPublisher<PaginatedModel<Movie>, Error> in
                guard let self else {
                    return Fail(error: RepositoryError.deallocated).eraseToAnyPublisher()
                }

                let movies = response.results.map { $0.toDomain() }

                return self.replaceCacheIfNeededAndSaveTrendingMovies(
                    movies,
                    shouldResetCache: shouldResetCache
                )
                .flatMap {
                    self.fetchTrendingMoviesFromCache(
                        pageSize: pageSize,
                        page: localPage,
                        totalPages: response.totalPages,
                        totalResults: response.totalResults
                    )
                }
                .eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<PaginatedModel<Movie>, Error> in
                Logger.error("Trending fetch failed. Falling back to cache. Error: \(error)")
                return fallbackCachedPage
            }
            .eraseToAnyPublisher()
    }

    /// Returns movie details while still using cache as the final source returned to the UI.
    ///
    /// If online, the repository refreshes the cached detail record first.
    /// If offline, it immediately falls back to the locally stored value.
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetail, Error> {
        let cachedDetails = fetchMovieDetailsFromCache(id: id)

        guard networkReachability.isConnected else {
            Logger.verbose("Offline: returning movie details from cache.")
            return cachedDetails
        }

        return fetchMovieDetailsFromAPI(id: id)
            .flatMap { [weak self] details -> AnyPublisher<Void, Error> in
                guard let self else {
                    return Fail(error: RepositoryError.deallocated).eraseToAnyPublisher()
                }

                return self.saveMovieDetailsIntoCache(details)
            }
            .flatMap { cachedDetails }
            .catch { error -> AnyPublisher<MovieDetail, Error> in
                Logger.error("Movie details fetch failed. Falling back to cache. Error: \(error)")
                return cachedDetails
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - API Reads

private extension MovieRepositoryImpl {
    /// Requests a trending movies page from the remote API.
    ///
    /// - Parameter page: One-based page number expected by the backend.
    /// - Returns: A publisher emitting the raw paginated API response.
    func fetchTrendingMoviesFromAPI(
        page: Int
    ) -> AnyPublisher<APIPaginatedResponse<MovieResponse>, Error> {
        apiService.request(MovieAPI.trendingMovies(page: page))
            .mapError { $0 }
            .eraseToAnyPublisher()
    }

    /// Requests detailed movie data from the remote API and maps it into the domain model.
    ///
    /// - Parameter id: The unique movie identifier.
    /// - Returns: A publisher emitting mapped `MovieDetail`.
    func fetchMovieDetailsFromAPI(id: Int) -> AnyPublisher<MovieDetail, Error> {
        apiService.request(MovieAPI.movieDetails(id: id))
            .map { (response: MovieDetailResponse) in
                response.toDomain()
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}

// MARK: - Cache Reads

private extension MovieRepositoryImpl {
    /// Reads a paginated slice of trending movies from local storage.
    ///
    /// The cached list is sorted by popularity in descending order so it matches
    /// the presentation order expected from the trending endpoint. If API metadata
    /// is available, it is preferred over locally computed totals.
    ///
    /// - Parameters:
    ///   - pageSize: Number of items per page.
    ///   - page: Zero-based local page index.
    ///   - totalPages: Optional total pages from the API response.
    ///   - totalResults: Optional total results from the API response.
    /// - Returns: A publisher emitting a domain `PaginatedModel`.
    func fetchTrendingMoviesFromCache(
        pageSize: Int,
        page: Int,
        totalPages: Int? = nil,
        totalResults: Int? = nil
    ) -> AnyPublisher<PaginatedModel<Movie>, Error> {
        moviePersistenceManager.fetch(
            sortedBy: [SortDescriptor(\CachedMovieEntity.popularity, order: .reverse)],
            pageSize: pageSize,
            page: page
        )
        .map { cachedPage in
            PaginatedModel(
                page: cachedPage.page + 1,
                results: cachedPage.results.map { $0.toDomain() },
                totalPages: totalPages ?? cachedPage.totalPages,
                totalResults: totalResults ?? cachedPage.totalResults
            )
        }
        .mapError { $0 }
        .eraseToAnyPublisher()
    }

    /// Reads a movie detail record from cache and reconstructs its genres.
    ///
    /// Movie entities store genre identifiers, so the associated genre rows are
    /// loaded separately and combined back into the domain model before returning.
    ///
    /// - Parameter id: The unique movie identifier.
    /// - Returns: A publisher emitting cached `MovieDetail`.
    func fetchMovieDetailsFromCache(id: Int) -> AnyPublisher<MovieDetail, Error> {
        moviePersistenceManager.fetch(byID: id)
            .flatMap { [genrePersistenceManager] cachedMovie in
                genrePersistenceManager.fetch(byIDs: cachedMovie.genreIds)
                    .map { cachedGenres in
                        cachedMovie.toDomain(genres: cachedGenres)
                    }
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}

// MARK: - Cache Writes

private extension MovieRepositoryImpl {
    /// Saves trending movies to cache, clearing old entries first when requested.
    ///
    /// This reset behavior is intentionally deferred until after a successful API
    /// response so that stale but useful cached data is not lost during failures.
    ///
    /// - Parameters:
    ///   - movies: Fresh movies returned by the trending endpoint.
    ///   - shouldResetCache: Indicates whether old cached trending items should be removed.
    /// - Returns: A publisher that completes when cache persistence finishes.
    func replaceCacheIfNeededAndSaveTrendingMovies(
        _ movies: [Movie],
        shouldResetCache: Bool
    ) -> AnyPublisher<Void, Error> {
        let savePublisher = saveTrendingMoviesIntoCache(movies)

        guard shouldResetCache else {
            return savePublisher
        }

        return moviePersistenceManager.deleteAll()
            .flatMap { savePublisher }
            .eraseToAnyPublisher()
    }

    /// Saves a list of movies as cached entities.
    ///
    /// - Parameter movies: Domain movies to persist locally.
    /// - Returns: A publisher that completes when all entities are stored.
    func saveTrendingMoviesIntoCache(_ movies: [Movie]) -> AnyPublisher<Void, Error> {
        let entities = movies.map { $0.toEntity() }

        return moviePersistenceManager.save(entities)
            .eraseToAnyPublisher()
    }

    /// Saves detailed movie data and its associated genres into cache.
    ///
    /// Genres are persisted first so the final cached movie detail can be rebuilt
    /// correctly later when the repository reads it back for the UI.
    ///
    /// - Parameter details: The detailed domain movie payload.
    /// - Returns: A publisher that completes when genres and movie details are saved.
    func saveMovieDetailsIntoCache(_ details: MovieDetail) -> AnyPublisher<Void, Error> {
        let genres = details.genres.map(CachedGenreEntity.init)
        let entity = details.toEntity()

        return genrePersistenceManager.save(genres)
            .flatMap { [moviePersistenceManager] in
                moviePersistenceManager.save(entity)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - RepositoryError

/// Internal repository error used when the repository is released before an
/// asynchronous publisher chain has finished executing.
enum RepositoryError: Error {
    case deallocated
}

// MARK: - Default Instance

extension MovieRepositoryImpl {
    /// Shared default repository used by the application.
    ///
    /// This wires the repository to the app's default networking layer,
    /// shared model container, and shared network reachability checker.
    static var `default`: MovieRepositoryImpl = {
        let apiService = NetworkService.default
        let container = AppModelContainer.shared.container

        return MovieRepositoryImpl(
            apiService: apiService,
            moviePersistenceManager: PersistenceManager<CachedMovieEntity>(container: container),
            genrePersistenceManager: PersistenceManager<CachedGenreEntity>(container: container),
            networkReachability: NetworkReachability.shared
        )
    }()
}
