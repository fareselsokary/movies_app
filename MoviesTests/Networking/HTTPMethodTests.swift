@testable import MoviesAppTask
import XCTest

final class HTTPMethodTests: XCTestCase {

    func test_get_rawValue() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
    }

    func test_post_rawValue() {
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
    }

    func test_put_rawValue() {
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
    }

    func test_delete_rawValue() {
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
    }

    func test_allCases_haveDistinctRawValues() {
        let rawValues = [HTTPMethod.get, .post, .put, .delete].map(\.rawValue)
        XCTAssertEqual(rawValues.count, Set(rawValues).count)
    }

    func test_initFromRawValue_get_succeeds() {
        XCTAssertEqual(HTTPMethod(rawValue: "GET"), .get)
    }

    func test_initFromRawValue_unknownString_returnsNil() {
        XCTAssertNil(HTTPMethod(rawValue: "PATCH"))
    }
}
