import Foundation
@testable import MoviesAppTask

final class MockNavigator: HomeNavigator {
    private(set) var showMovieDetailCallCount = 0
    private(set) var lastMovieDetailId: Int?

    func showMovieDetail(id: Int) {
        showMovieDetailCallCount += 1
        lastMovieDetailId = id
    }
}
