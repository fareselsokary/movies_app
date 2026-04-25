import Combine
import Foundation
@testable import MoviesAppTask

final class MockMovieDetailUseCase: MovieDetailUseCaseProtocol {
    var movieDetailResult: AnyPublisher<MovieDetail, Error> = Empty().eraseToAnyPublisher()

    private(set) var fetchCallCount = 0
    private(set) var lastFetchedMovieId: Int?

    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetail, Error> {
        fetchCallCount += 1
        lastFetchedMovieId = movieId
        return movieDetailResult
    }
}
