@testable import MoviesAppTask
import XCTest

final class GenreTests: XCTestCase {

    func test_init_setsIdAndName() {
        let genre = Genre(id: 28, name: "Action")
        XCTAssertEqual(genre.id, 28)
        XCTAssertEqual(genre.name, "Action")
    }

    func test_identifiable_returnsCorrectId() {
        let genre = Genre(id: 99, name: "Thriller")
        XCTAssertEqual(genre.id, 99)
    }

    func test_hashable_sameProperties_areEqual() {
        let g1 = Genre(id: 12, name: "Adventure")
        let g2 = Genre(id: 12, name: "Adventure")
        XCTAssertEqual(g1, g2)
    }

    func test_hashable_differentId_notEqual() {
        let g1 = Genre(id: 12, name: "Adventure")
        let g2 = Genre(id: 28, name: "Adventure")
        XCTAssertNotEqual(g1, g2)
    }

    func test_hashable_differentName_notEqual() {
        let g1 = Genre(id: 28, name: "Action")
        let g2 = Genre(id: 28, name: "Adventure")
        XCTAssertNotEqual(g1, g2)
    }

    func test_hashable_usableAsSetElement() {
        let g1 = Genre(id: 28, name: "Action")
        let g2 = Genre(id: 28, name: "Action")
        let set: Set<Genre> = [g1, g2]
        XCTAssertEqual(set.count, 1)
    }

    func test_hashable_differentGenres_bothStoredInSet() {
        let g1 = Genre(id: 28, name: "Action")
        let g2 = Genre(id: 12, name: "Adventure")
        let set: Set<Genre> = [g1, g2]
        XCTAssertEqual(set.count, 2)
    }
}
