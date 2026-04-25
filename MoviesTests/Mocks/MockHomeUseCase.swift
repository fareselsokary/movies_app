import Combine
import Foundation
@testable import MoviesAppTask

final class MockHomeUseCase: HomeUseCaseProtocol {
    var trendingMoviesResult: AnyPublisher<PaginatedModel<Movie>, Error> = Empty().eraseToAnyPublisher()
    var genresResult: AnyPublisher<[Genre], Error> = Empty().eraseToAnyPublisher()

    private(set) var fetchTrendingCallCount = 0
    private(set) var fetchGenresCallCount = 0
    private(set) var lastRequestedPage: Int?
    private(set) var lastRequestedPageSize: Int?
    private(set) var lastShouldResetCache: Bool?

    func fetchTrendingMovies(
        pageSize: Int,
        page: Int,
        shouldResetCache: Bool
    ) -> AnyPublisher<PaginatedModel<Movie>, Error> {
        fetchTrendingCallCount += 1
        lastRequestedPageSize = pageSize
        lastRequestedPage = page
        lastShouldResetCache = shouldResetCache
        return trendingMoviesResult
    }

    func fetchMovieGenres() -> AnyPublisher<[Genre], Error> {
        fetchGenresCallCount += 1
        return genresResult
    }
}
