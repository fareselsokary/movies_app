import XCTest
@testable import MoviesAppTask

final class ArrayUniquedTests: XCTestCase {

    func test_unique_byValue_removesExactDuplicates() {
        let input = [1, 2, 2, 3, 3, 3]
        let result = input.unique(by: { $0 })
        XCTAssertEqual(result, [1, 2, 3])
    }

    func test_unique_byProperty_keepsFirstOccurrence() {
        struct Item { let id: Int; let name: String }
        let items = [
            Item(id: 1, name: "First"),
            Item(id: 2, name: "Second"),
            Item(id: 1, name: "Duplicate")
        ]
        let result = items.unique(by: { $0.id })
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "First")
        XCTAssertEqual(result[1].name, "Second")
    }

    func test_unique_emptyArray_returnsEmpty() {
        let input: [Int] = []
        let result = input.unique(by: { $0 })
        XCTAssertTrue(result.isEmpty)
    }

    func test_unique_noDuplicates_returnsAll() {
        let input = [1, 2, 3]
        let result = input.unique(by: { $0 })
        XCTAssertEqual(result, [1, 2, 3])
    }

    func test_unique_allDuplicates_returnsOneElement() {
        let input = [5, 5, 5]
        let result = input.unique(by: { $0 })
        XCTAssertEqual(result, [5])
    }

    func test_unique_preservesOriginalOrder() {
        let input = [3, 1, 2, 1, 3]
        let result = input.unique(by: { $0 })
        XCTAssertEqual(result, [3, 1, 2])
    }
}
