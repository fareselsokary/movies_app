@testable import MoviesAppTask
import XCTest

final class MovieAPITests: XCTestCase {

    // MARK: - Path

    func test_trendingMovies_path_isCorrect() {
        XCTAssertEqual(MovieAPI.trendingMovies(page: 1).path, "discover/movie")
    }

    func test_movieDetails_path_containsCorrectId() {
        XCTAssertEqual(MovieAPI.movieDetails(id: 42).path, "movie/42")
    }

    func test_movieDetails_path_usesProvidedId() {
        XCTAssertEqual(MovieAPI.movieDetails(id: 999).path, "movie/999")
    }

    // MARK: - HTTP Method

    func test_trendingMovies_method_isGet() {
        XCTAssertEqual(MovieAPI.trendingMovies(page: 1).method, .get)
    }

    func test_movieDetails_method_isGet() {
        XCTAssertEqual(MovieAPI.movieDetails(id: 1).method, .get)
    }

    // MARK: - Parameters

    func test_trendingMovies_parameters_containsPageNumber() {
        let params = MovieAPI.trendingMovies(page: 3).parameters
        let page = params?["page"] as? Int
        XCTAssertEqual(page, 3)
    }

    func test_trendingMovies_parameters_sortByPopularityDesc() {
        let params = MovieAPI.trendingMovies(page: 1).parameters
        let sortBy = params?["sort_by"] as? String
        XCTAssertEqual(sortBy, "popularity.desc")
    }

    func test_trendingMovies_parameters_includeAdultIsFalse() {
        let params = MovieAPI.trendingMovies(page: 1).parameters
        let includeAdult = params?["include_adult"] as? Bool
        XCTAssertEqual(includeAdult, false)
    }

    func test_movieDetails_parameters_isNil() {
        XCTAssertNil(MovieAPI.movieDetails(id: 1).parameters)
    }
}
