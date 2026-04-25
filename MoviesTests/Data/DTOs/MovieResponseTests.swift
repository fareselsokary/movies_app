@testable import MoviesAppTask
import XCTest

final class MovieResponseTests: XCTestCase {
    private let decoder = JSONDecoder()

    private var validJSON: Data {
        """
        {
            "id": 123,
            "title": "Test Movie",
            "poster_path": "/abc.jpg",
            "release_date": "2024-03-15",
            "genre_ids": [28, 12],
            "popularity": 99.5
        }
        """.data(using: .utf8)!
    }

    func test_decode_validJSON_decodesAllFields() throws {
        let movie = try decoder.decode(MovieResponse.self, from: validJSON)

        XCTAssertEqual(movie.id, 123)
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.posterPath, "/abc.jpg")
        XCTAssertEqual(movie.genreIds, [28, 12])
        XCTAssertEqual(movie.popularity, 99.5)
    }

    func test_decode_validReleaseDate_parsedCorrectly() throws {
        let movie = try decoder.decode(MovieResponse.self, from: validJSON)

        XCTAssertNotNil(movie.releaseDate)
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        XCTAssertEqual(calendar.component(.year, from: movie.releaseDate!), 2024)
        XCTAssertEqual(calendar.component(.month, from: movie.releaseDate!), 3)
    }

    func test_decode_invalidReleaseDate_setToNil() throws {
        let json = """
        {
            "id": 1,
            "release_date": "not-a-date"
        }
        """.data(using: .utf8)!

        let movie = try decoder.decode(MovieResponse.self, from: json)

        XCTAssertNil(movie.releaseDate)
    }

    func test_decode_missingOptionalFields_usesDefaults() throws {
        let json = """
        {"id": 99}
        """.data(using: .utf8)!

        let movie = try decoder.decode(MovieResponse.self, from: json)

        XCTAssertEqual(movie.title, "")
        XCTAssertEqual(movie.posterPath, "")
        XCTAssertEqual(movie.popularity, 0)
        XCTAssertTrue(movie.genreIds.isEmpty)
        XCTAssertNil(movie.releaseDate)
    }

    func test_decode_missingId_throws() {
        let json = """
        {"title": "No ID"}
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(MovieResponse.self, from: json))
    }

    func test_decode_snakeCaseKeys_mapCorrectly() throws {
        let movie = try decoder.decode(MovieResponse.self, from: validJSON)

        XCTAssertFalse(movie.posterPath.isEmpty)
        XCTAssertFalse(movie.genreIds.isEmpty)
    }
}
