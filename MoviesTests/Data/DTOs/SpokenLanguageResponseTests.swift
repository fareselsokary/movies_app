@testable import MoviesAppTask
import XCTest

final class SpokenLanguageResponseTests: XCTestCase {
    private let decoder = JSONDecoder()

    func test_decode_validJSON_decodesAllFields() throws {
        let json = """
        {"iso_639_1": "en", "name": "English"}
        """.data(using: .utf8)!

        let lang = try decoder.decode(SpokenLanguageResponse.self, from: json)

        XCTAssertEqual(lang.iso6391, "en")
        XCTAssertEqual(lang.name, "English")
    }

    func test_decode_snakeCaseKey_mapsToIso6391() throws {
        let json = """
        {"iso_639_1": "fr", "name": "French"}
        """.data(using: .utf8)!

        let lang = try decoder.decode(SpokenLanguageResponse.self, from: json)

        XCTAssertEqual(lang.iso6391, "fr")
    }

    func test_decode_missingName_throws() {
        let json = """
        {"iso_639_1": "en"}
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(SpokenLanguageResponse.self, from: json))
    }

    func test_decode_missingIsoCode_throws() {
        let json = """
        {"name": "English"}
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(SpokenLanguageResponse.self, from: json))
    }
}
