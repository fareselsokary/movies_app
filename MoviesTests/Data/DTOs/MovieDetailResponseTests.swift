@testable import MoviesAppTask
import XCTest

final class MovieDetailResponseTests: XCTestCase {
    private let decoder = JSONDecoder()

    private var validJSON: Data {
        """
        {
            "id": 42,
            "title": "Detailed Movie",
            "overview": "A great film",
            "poster_path": "/poster.jpg",
            "backdrop_path": "/backdrop.jpg",
            "release_date": "2023-07-21",
            "genres": [{"id": 28, "name": "Action"}],
            "homepage": "https://example.com",
            "budget": 200000000.0,
            "revenue": 850000000.0,
            "spoken_languages": [{"iso_639_1": "en", "name": "English"}],
            "status": "Released",
            "runtime": 150.0
        }
        """.data(using: .utf8)!
    }

    func test_decode_validJSON_decodesScalarFields() throws {
        let detail = try decoder.decode(MovieDetailResponse.self, from: validJSON)

        XCTAssertEqual(detail.id, 42)
        XCTAssertEqual(detail.title, "Detailed Movie")
        XCTAssertEqual(detail.overview, "A great film")
        XCTAssertEqual(detail.posterPath, "/poster.jpg")
        XCTAssertEqual(detail.backdropPath, "/backdrop.jpg")
        XCTAssertEqual(detail.homepage, "https://example.com")
        XCTAssertEqual(detail.budget, 200_000_000)
        XCTAssertEqual(detail.revenue, 850_000_000)
        XCTAssertEqual(detail.status, "Released")
        XCTAssertEqual(detail.runtime, 150)
    }

    func test_decode_validJSON_decodesNestedGenres() throws {
        let detail = try decoder.decode(MovieDetailResponse.self, from: validJSON)

        XCTAssertEqual(detail.genres.count, 1)
        XCTAssertEqual(detail.genres[0].id, 28)
        XCTAssertEqual(detail.genres[0].name, "Action")
    }

    func test_decode_validJSON_decodesSpokenLanguages() throws {
        let detail = try decoder.decode(MovieDetailResponse.self, from: validJSON)

        XCTAssertEqual(detail.spokenLanguages.count, 1)
        XCTAssertEqual(detail.spokenLanguages[0].iso6391, "en")
        XCTAssertEqual(detail.spokenLanguages[0].name, "English")
    }

    func test_decode_validReleaseDate_parsedCorrectly() throws {
        let detail = try decoder.decode(MovieDetailResponse.self, from: validJSON)

        XCTAssertNotNil(detail.releaseDate)
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        XCTAssertEqual(calendar.component(.year, from: detail.releaseDate!), 2023)
        XCTAssertEqual(calendar.component(.month, from: detail.releaseDate!), 7)
    }

    func test_decode_missingOptionalFields_usesDefaults() throws {
        let json = """
        {
            "id": 1,
            "title": "Minimal",
            "genres": [],
            "spoken_languages": []
        }
        """.data(using: .utf8)!

        let detail = try decoder.decode(MovieDetailResponse.self, from: json)

        XCTAssertEqual(detail.overview, "")
        XCTAssertEqual(detail.posterPath, "")
        XCTAssertEqual(detail.backdropPath, "")
        XCTAssertNil(detail.releaseDate)
        XCTAssertNil(detail.homepage)
        XCTAssertNil(detail.budget)
        XCTAssertNil(detail.revenue)
        XCTAssertNil(detail.status)
        XCTAssertNil(detail.runtime)
    }

    func test_decode_missingId_throws() {
        let json = """
        {"title": "No ID", "genres": [], "spoken_languages": []}
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(MovieDetailResponse.self, from: json))
    }

    func test_decode_missingTitle_throws() {
        let json = """
        {"id": 1, "genres": [], "spoken_languages": []}
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(MovieDetailResponse.self, from: json))
    }
}
