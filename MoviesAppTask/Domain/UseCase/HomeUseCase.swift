import Combine
import Foundation

// MARK: - HomeUseCaseProtocol

/// Protocol defining the use case for the Home screen.
///
/// Abstracts movie and genre data operations away from the ViewModel,
/// keeping business logic centralized and easily testable.
protocol HomeUseCaseProtocol {
    /// Fetches a paginated list of trending movies.
    /// - Parameters:
    ///   - pageSize: Number of items per page.
    ///   - page: The page index to fetch.
    /// - Returns: A publisher emitting a paginated result of `MovieModel`.
    func fetchTrendingMovies(
        pageSize: Int,
        page: Int,
        shouldResetCache: Bool
    ) -> AnyPublisher<PaginatedModel<Movie>, Error>

    /// Fetches all available movie genres.
    /// - Returns: A publisher emitting an array of `GenreModel`.
    func fetchMovieGenres() -> AnyPublisher<[Genre], Error>
}

// MARK: - HomeUseCase

/// Concrete implementation of `HomeUseCaseProtocol`.
///
/// Delegates to `MovieRepositoryProtocol` and `GenresRepositoryProtocol`
/// for data retrieval, keeping the ViewModel free of repository concerns.
final class HomeUseCase: HomeUseCaseProtocol {
    // MARK: - Dependencies

    private let movieRepository: MovieRepositoryImpl
    private let genreRepository: GenresRepositoryImpl

    // MARK: - Initialization

    /// Initializes the use case with required repositories.
    /// - Parameters:
    ///   - movieRepository: Repository responsible for movie data.
    ///   - genreRepository: Repository responsible for genre data.
    init(
        movieRepository: MovieRepositoryImpl = MovieRepositoryImpl.default,
        genreRepository: GenresRepositoryImpl = GenresRepositoryImpl.default
    ) {
        self.movieRepository = movieRepository
        self.genreRepository = genreRepository
    }

    // MARK: - HomeUseCaseProtocol

    func fetchTrendingMovies(
        pageSize: Int,
        page: Int,
        shouldResetCache: Bool
    ) -> AnyPublisher<PaginatedModel<Movie>, Error> {
        movieRepository.fetchTrendingMovies(
            pageSize: pageSize,
            page: page,
            shouldResetCache: shouldResetCache
        )
    }

    func fetchMovieGenres() -> AnyPublisher<[Genre], Error> {
        genreRepository.fetchMovieGenres()
    }
}
