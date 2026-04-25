@testable import MoviesAppTask
import XCTest

final class APIPaginatedResponseTests: XCTestCase {
    private let decoder = JSONDecoder()

    func test_decode_validJSON_decodesAllFields() throws {
        let json = """
        {
            "page": 2,
            "results": [],
            "total_pages": 100,
            "total_results": 2000
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(APIPaginatedResponse<GenreResponse>.self, from: json)

        XCTAssertEqual(response.page, 2)
        XCTAssertEqual(response.totalPages, 100)
        XCTAssertEqual(response.totalResults, 2000)
        XCTAssertTrue(response.results.isEmpty)
    }

    func test_decode_withResults_decodesResultsArray() throws {
        let json = """
        {
            "page": 1,
            "results": [
                {"id": 28, "name": "Action"},
                {"id": 12, "name": "Adventure"}
            ],
            "total_pages": 5,
            "total_results": 10
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(APIPaginatedResponse<GenreResponse>.self, from: json)

        XCTAssertEqual(response.results.count, 2)
        XCTAssertEqual(response.results[0].name, "Action")
        XCTAssertEqual(response.results[1].id, 12)
    }

    func test_decode_snakeCaseKeys_mapToCorrectProperties() throws {
        let json = """
        {
            "page": 1,
            "results": [],
            "total_pages": 42,
            "total_results": 840
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(APIPaginatedResponse<GenreResponse>.self, from: json)

        XCTAssertEqual(response.totalPages, 42)
        XCTAssertEqual(response.totalResults, 840)
    }

    func test_decode_missingRequiredField_throws() {
        let json = """
        {
            "page": 1,
            "results": [],
            "total_pages": 5
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(APIPaginatedResponse<GenreResponse>.self, from: json))
    }
}
