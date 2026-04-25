@testable import MoviesAppTask
import XCTest

final class MovieTests: XCTestCase {
    private let testDate = DateFormatter.yyyyMMdd.date(from: "2024-06-15")

    func test_init_setsAllProperties() {
        let movie = Movie(
            id: 1, title: "Test Movie", posterPath: "/poster.jpg",
            releaseDate: testDate, genreIds: [28, 12], popularity: 95.5
        )
        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.posterPath, "/poster.jpg")
        XCTAssertEqual(movie.releaseDate, testDate)
        XCTAssertEqual(movie.genreIds, [28, 12])
        XCTAssertEqual(movie.popularity, 95.5)
    }

    func test_init_nilReleaseDate_isAllowed() {
        let movie = Movie(id: 1, title: "", posterPath: "", releaseDate: nil, genreIds: [], popularity: 0)
        XCTAssertNil(movie.releaseDate)
    }

    func test_identifiable_returnsCorrectId() {
        let movie = Movie(id: 42, title: "", posterPath: "", releaseDate: nil, genreIds: [], popularity: 0)
        XCTAssertEqual(movie.id, 42)
    }

    func test_hashable_sameProperties_areEqual() {
        let m1 = Movie(id: 1, title: "Film", posterPath: "/p.jpg", releaseDate: nil, genreIds: [28], popularity: 50.0)
        let m2 = Movie(id: 1, title: "Film", posterPath: "/p.jpg", releaseDate: nil, genreIds: [28], popularity: 50.0)
        XCTAssertEqual(m1, m2)
    }

    func test_hashable_differentId_notEqual() {
        let m1 = Movie(id: 1, title: "Film", posterPath: "", releaseDate: nil, genreIds: [], popularity: 0)
        let m2 = Movie(id: 2, title: "Film", posterPath: "", releaseDate: nil, genreIds: [], popularity: 0)
        XCTAssertNotEqual(m1, m2)
    }

    func test_hashable_usableAsSetElement() {
        let m1 = Movie(id: 1, title: "Film", posterPath: "", releaseDate: nil, genreIds: [], popularity: 0)
        let m2 = Movie(id: 1, title: "Film", posterPath: "", releaseDate: nil, genreIds: [], popularity: 0)
        let set: Set<Movie> = [m1, m2]
        XCTAssertEqual(set.count, 1)
    }
}
