import Combine
import Foundation

// MARK: - GenresRepositoryImpl

/// A repository that manages movie genres using persistence as the
/// single source of truth (SSOT).
///
/// ## Data Flow
/// ```
/// Online:   API → Save to Cache → Emit from Cache → UI
/// Offline:  Cache → UI
/// ```
///
/// The UI never observes network responses directly. The network's role is
/// limited to *updating* the cache, which guarantees consistency between
/// what is persisted and what is displayed.
class GenresRepositoryImpl: GenresRepository {
    // MARK: Dependencies

    private let apiService: NetworkServiceProtocol
    private let persistenceManager: PersistenceManager<CachedGenreEntity>
    private let networkReachability: NetworkReachabilityProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    /// Creates a new `GenresRepositoryImpl`.
    ///
    /// - Parameters:
    ///   - apiService: The network service used for remote API calls.
    ///   - persistenceManager: The local cache manager for genre entities.
    ///   - networkReachability: The connectivity monitor used to decide
    ///                          between online and offline paths.
    init(
        apiService: NetworkServiceProtocol = NetworkService.default,
        persistenceManager: PersistenceManager<CachedGenreEntity>,
        networkReachability: NetworkReachabilityProtocol
    ) {
        self.apiService = apiService
        self.persistenceManager = persistenceManager
        self.networkReachability = networkReachability
    }

    // MARK: - Public API

    /// Fetches movie genres, using persistence as the single source of truth.
    ///
    /// - If the device is online: refreshes cache from the API, then emits
    ///   the newly-saved values from the cache.
    /// - If the device is offline: emits directly from the cache.
    /// - If the network call fails while online: falls back to the cache.
    func fetchMovieGenres() -> AnyPublisher<[Genre], Error> {
        Logger.verbose("Fetching movie genres...")

        guard networkReachability.isConnected else {
            Logger.verbose("Offline: returning cached genres.")
            return fetchGenresFromCache()
        }

        return refreshGenresFromNetwork()
            .catch { [weak self] error -> AnyPublisher<[Genre], Error> in
                Logger.error("Network failed: \(error). Falling back to cache.")
                return self?.fetchGenresFromCache()
                    ?? Empty().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Private Helpers

private extension GenresRepositoryImpl {
    /// Fetches genres from the remote API, saves them to the cache, then
    /// emits the freshly-cached values.
    ///
    /// This is the "happy path" when online. It ensures the UI always
    /// receives data that matches what is persisted.
    func refreshGenresFromNetwork() -> AnyPublisher<[Genre], Error> {
        fetchGenresFromAPI()
            .flatMap { [weak self] genres -> AnyPublisher<[Genre], Error> in
                guard let self else {
                    return Fail(error: NetworkError.unknown(nil))
                        .eraseToAnyPublisher()
                }
                return self.saveGenres(genres)
                    .flatMap { _ in self.fetchGenresFromCache() }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Performs the raw API request and maps the response into domain models.
    ///
    /// - Returns: A publisher emitting the decoded `[Genre]` list.
    func fetchGenresFromAPI() -> AnyPublisher<[Genre], Error> {
        apiService.request(GenreAPI.listGenres)
            .map { (response: GenreListResponse) in
                response.genres.map { $0.toDomain() }
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    /// Reads genres from the local cache.
    ///
    /// - Returns: A publisher emitting the cached `[Genre]`, or an empty
    ///            array if the cache has no entries.
    func fetchGenresFromCache() -> AnyPublisher<[Genre], Error> {
        persistenceManager.fetch()
            .map { $0.results.map { $0.toDomain() } }
            .eraseToAnyPublisher()
    }

    /// Persists the given genres to the local cache.
    ///
    /// - Parameter genres: The domain-level genres to cache.
    /// - Returns: A publisher completing once the save is finished.
    func saveGenres(_ genres: [Genre]) -> AnyPublisher<Void, Error> {
        let cachedEntities = genres.map { $0.toEntity() }
        return persistenceManager.save(cachedEntities)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

// MARK: - Default Instance

extension GenresRepositoryImpl {
    /// A shared default instance wired with standard dependencies.
    ///
    /// Use this for production code paths; inject custom dependencies in
    /// tests or alternative configurations.
    static let `default`: GenresRepositoryImpl = {
        let apiService = NetworkService.default
        let container = AppModelContainer.shared.container
        let persistenceManager = PersistenceManager<CachedGenreEntity>(container: container)

        return GenresRepositoryImpl(
            apiService: apiService,
            persistenceManager: persistenceManager,
            networkReachability: NetworkReachability.shared
        )
    }()
}
