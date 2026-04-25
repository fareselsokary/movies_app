import Combine
import Foundation

// MARK: - MovieDetailUseCaseProtocol

/// Protocol defining the use case for the Movie Detail screen.
protocol MovieDetailUseCaseProtocol {
    /// Fetches full details for a specific movie.
    /// - Parameter movieId: The unique identifier of the movie.
    /// - Returns: A publisher emitting a `MovieDetailModel`.
    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetail, Error>
}

// MARK: - MovieDetailUseCase

/// Concrete implementation of `MovieDetailUseCaseProtocol`.
///
/// Delegates to `MovieRepositoryProtocol` for data retrieval.
final class MovieDetailUseCase: MovieDetailUseCaseProtocol {
    // MARK: - Dependencies

    private let movieRepository: MovieRepositoryImpl

    // MARK: - Initialization

    /// Initializes the use case with a movie repository.
    /// - Parameter movieRepository: Repository responsible for movie data.
    init(movieRepository: MovieRepositoryImpl = MovieRepositoryImpl.default) {
        self.movieRepository = movieRepository
    }

    // MARK: - MovieDetailUseCaseProtocol

    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetail, Error> {
        movieRepository.fetchMovieDetails(id: movieId)
    }
}
