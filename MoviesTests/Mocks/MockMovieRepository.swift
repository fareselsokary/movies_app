import Combine
import Foundation
@testable import MoviesAppTask

final class MockMovieRepository: MovieRepository {
    var trendingMoviesResult: AnyPublisher<PaginatedModel<Movie>, Error> = Empty().eraseToAnyPublisher()
    var movieDetailsResult: AnyPublisher<MovieDetail, Error> = Empty().eraseToAnyPublisher()

    private(set) var fetchTrendingCallCount = 0
    private(set) var fetchDetailsCallCount = 0
    private(set) var lastRequestedPage: Int?
    private(set) var lastRequestedPageSize: Int?
    private(set) var lastFetchedMovieId: Int?
    private(set) var lastShouldResetCache: Bool?

    func fetchTrendingMovies(
        pageSize: Int,
        page: Int,
        shouldResetCache: Bool
    ) -> AnyPublisher<PaginatedModel<Movie>, Error> {
        fetchTrendingCallCount += 1
        lastRequestedPage = page
        lastRequestedPageSize = pageSize
        lastShouldResetCache = shouldResetCache
        return trendingMoviesResult
    }

    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetail, Error> {
        fetchDetailsCallCount += 1
        lastFetchedMovieId = id
        return movieDetailsResult
    }
}
