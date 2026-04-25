@testable import MoviesAppTask
import XCTest

final class PaginatedModelTests: XCTestCase {

    func test_init_setsAllProperties() {
        let movies = [Movie(id: 1, title: "Film", posterPath: "", releaseDate: nil, genreIds: [], popularity: 0)]
        let model = PaginatedModel(page: 2, results: movies, totalPages: 10, totalResults: 200)

        XCTAssertEqual(model.page, 2)
        XCTAssertEqual(model.results.count, 1)
        XCTAssertEqual(model.totalPages, 10)
        XCTAssertEqual(model.totalResults, 200)
    }

    func test_init_emptyResults_isAllowed() {
        let model = PaginatedModel<Movie>(page: 1, results: [], totalPages: 0, totalResults: 0)
        XCTAssertTrue(model.results.isEmpty)
    }

    func test_init_withGenreResults_worksForGenericType() {
        let genres = [Genre(id: 28, name: "Action"), Genre(id: 12, name: "Adventure")]
        let model = PaginatedModel(page: 1, results: genres, totalPages: 1, totalResults: 2)

        XCTAssertEqual(model.results.count, 2)
        XCTAssertEqual(model.results[0].name, "Action")
        XCTAssertEqual(model.results[1].id, 12)
    }

    func test_init_pageAndTotals_storedCorrectly() {
        let model = PaginatedModel<Genre>(page: 5, results: [], totalPages: 20, totalResults: 400)

        XCTAssertEqual(model.page, 5)
        XCTAssertEqual(model.totalPages, 20)
        XCTAssertEqual(model.totalResults, 400)
    }
}
