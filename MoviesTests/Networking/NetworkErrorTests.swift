@testable import MoviesAppTask
import XCTest

final class NetworkErrorTests: XCTestCase {

    // MARK: - Equatable

    func test_equal_invalidURL_isEqual() {
        XCTAssertEqual(NetworkError.invalidURL, .invalidURL)
    }

    func test_equal_noData_isEqual() {
        XCTAssertEqual(NetworkError.noData, .noData)
    }

    func test_equal_badRequest_isEqual() {
        XCTAssertEqual(NetworkError.badRequest, .badRequest)
    }

    func test_equal_serverError_sameCodeAndMessage_isEqual() {
        XCTAssertEqual(
            NetworkError.serverError(statusCode: 404, message: "Not Found"),
            NetworkError.serverError(statusCode: 404, message: "Not Found")
        )
    }

    func test_equal_serverError_differentStatusCode_notEqual() {
        XCTAssertNotEqual(
            NetworkError.serverError(statusCode: 404, message: nil),
            NetworkError.serverError(statusCode: 500, message: nil)
        )
    }

    func test_equal_serverError_differentMessage_notEqual() {
        XCTAssertNotEqual(
            NetworkError.serverError(statusCode: 404, message: "Not Found"),
            NetworkError.serverError(statusCode: 404, message: "Missing")
        )
    }

    func test_equal_serverError_nilMessage_isEqual() {
        XCTAssertEqual(
            NetworkError.serverError(statusCode: 500, message: nil),
            NetworkError.serverError(statusCode: 500, message: nil)
        )
    }

    func test_equal_unknown_bothNil_isEqual() {
        XCTAssertEqual(NetworkError.unknown(nil), NetworkError.unknown(nil))
    }

    func test_equal_differentCases_notEqual() {
        XCTAssertNotEqual(NetworkError.invalidURL, .noData)
        XCTAssertNotEqual(NetworkError.noData, .badRequest)
        XCTAssertNotEqual(NetworkError.invalidURL, .badRequest)
    }

    func test_equal_serverErrorVsInvalidURL_notEqual() {
        XCTAssertNotEqual(
            NetworkError.serverError(statusCode: 404, message: nil),
            NetworkError.invalidURL
        )
    }

    // MARK: - LocalizedError

    func test_errorDescription_invalidURL_isNotNil() {
        XCTAssertNotNil(NetworkError.invalidURL.errorDescription)
    }

    func test_errorDescription_noData_isNotNil() {
        XCTAssertNotNil(NetworkError.noData.errorDescription)
    }

    func test_errorDescription_badRequest_isNotNil() {
        XCTAssertNotNil(NetworkError.badRequest.errorDescription)
    }

    func test_errorDescription_serverError_containsStatusCode() {
        let desc = NetworkError.serverError(statusCode: 404, message: "Not Found").errorDescription
        XCTAssertTrue(desc?.contains("404") == true)
    }

    func test_errorDescription_serverError_containsMessage() {
        let desc = NetworkError.serverError(statusCode: 500, message: "Internal Error").errorDescription
        XCTAssertTrue(desc?.contains("Internal Error") == true)
    }

    func test_errorDescription_unknown_isNotNil() {
        XCTAssertNotNil(NetworkError.unknown(nil).errorDescription)
    }

    func test_errorDescription_decodingError_containsDescription() {
        let underlying = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "bad JSON"])
        let desc = NetworkError.decodingError(underlying).errorDescription
        XCTAssertNotNil(desc)
    }
}
