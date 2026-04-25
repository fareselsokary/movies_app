import Combine
import Foundation
@testable import MoviesAppTask

final class MockGenresRepository: GenresRepository {
    var genresResult: AnyPublisher<[Genre], Error> = Empty().eraseToAnyPublisher()

    private(set) var fetchCallCount = 0

    func fetchMovieGenres() -> AnyPublisher<[Genre], Error> {
        fetchCallCount += 1
        return genresResult
    }
}
