@testable import MoviesAppTask
import XCTest

final class GenreAPITests: XCTestCase {

    func test_listGenres_path_isCorrect() {
        XCTAssertEqual(GenreAPI.listGenres.path, "genre/movie/list")
    }

    func test_listGenres_method_isGet() {
        XCTAssertEqual(GenreAPI.listGenres.method, .get)
    }

    func test_listGenres_parameters_isNil() {
        XCTAssertNil(GenreAPI.listGenres.parameters)
    }
}
