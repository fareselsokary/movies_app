@testable import MoviesAppTask
import XCTest

final class GenreResponseTests: XCTestCase {
    private let decoder = JSONDecoder()

    // MARK: - GenreResponse

    func test_decode_validJSON_decodesIdAndName() throws {
        let json = """
        {"id": 28, "name": "Action"}
        """.data(using: .utf8)!

        let genre = try decoder.decode(GenreResponse.self, from: json)

        XCTAssertEqual(genre.id, 28)
        XCTAssertEqual(genre.name, "Action")
    }

    func test_decode_missingId_throws() {
        let json = """
        {"name": "Action"}
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(GenreResponse.self, from: json))
    }

    func test_decode_missingName_throws() {
        let json = """
        {"id": 28}
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(GenreResponse.self, from: json))
    }

    // MARK: - GenreListResponse

    func test_decode_genreListResponse_validJSON_decodesArray() throws {
        let json = """
        {
            "genres": [
                {"id": 28, "name": "Action"},
                {"id": 12, "name": "Adventure"}
            ]
        }
        """.data(using: .utf8)!

        let list = try decoder.decode(GenreListResponse.self, from: json)

        XCTAssertEqual(list.genres.count, 2)
        XCTAssertEqual(list.genres[0].name, "Action")
        XCTAssertEqual(list.genres[1].id, 12)
    }

    func test_decode_genreListResponse_emptyArray_decodesEmpty() throws {
        let json = """
        {"genres": []}
        """.data(using: .utf8)!

        let list = try decoder.decode(GenreListResponse.self, from: json)

        XCTAssertTrue(list.genres.isEmpty)
    }
}
