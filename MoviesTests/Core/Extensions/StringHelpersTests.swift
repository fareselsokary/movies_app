import XCTest
@testable import MoviesAppTask

final class StringHelpersTests: XCTestCase {

    // MARK: - Optional String

    func test_isEmptyOrNil_nil_returnsTrue() {
        let value: String? = nil
        XCTAssertTrue(value.isEmptyOrNil)
    }

    func test_isEmptyOrNil_emptyString_returnsTrue() {
        let value: String? = ""
        XCTAssertTrue(value.isEmptyOrNil)
    }

    func test_isEmptyOrNil_whitespaceOnly_returnsTrue() {
        let value: String? = "   "
        XCTAssertTrue(value.isEmptyOrNil)
    }

    func test_isEmptyOrNil_newlineOnly_returnsTrue() {
        let value: String? = "\n"
        XCTAssertTrue(value.isEmptyOrNil)
    }

    func test_isEmptyOrNil_validString_returnsFalse() {
        let value: String? = "Hello"
        XCTAssertFalse(value.isEmptyOrNil)
    }

    func test_isNotEmptyOrNotNil_nil_returnsFalse() {
        let value: String? = nil
        XCTAssertFalse(value.isNotEmptyOrNotNil)
    }

    func test_isNotEmptyOrNotNil_validString_returnsTrue() {
        let value: String? = "Hello"
        XCTAssertTrue(value.isNotEmptyOrNotNil)
    }

    func test_isNotEmptyOrNotNil_isInverseOfIsEmptyOrNil() {
        let values: [String?] = [nil, "", "  ", "Hello"]
        for value in values {
            XCTAssertEqual(value.isNotEmptyOrNotNil, !value.isEmptyOrNil)
        }
    }

    // MARK: - String

    func test_trimmingWhiteSpacesAndNewlines_removesLeadingSpaces() {
        XCTAssertEqual("  Hello".trimmingWhiteSpacesAndNewlines(), "Hello")
    }

    func test_trimmingWhiteSpacesAndNewlines_removesTrailingSpaces() {
        XCTAssertEqual("Hello  ".trimmingWhiteSpacesAndNewlines(), "Hello")
    }

    func test_trimmingWhiteSpacesAndNewlines_removesNewlines() {
        XCTAssertEqual("\nHello\n".trimmingWhiteSpacesAndNewlines(), "Hello")
    }

    func test_trimmingWhiteSpacesAndNewlines_noWhitespace_returnsSameString() {
        XCTAssertEqual("Hello".trimmingWhiteSpacesAndNewlines(), "Hello")
    }

    func test_isBlankString_emptyString_returnsTrue() {
        XCTAssertTrue("".isBlankString)
    }

    func test_isBlankString_whitespaceOnly_returnsTrue() {
        XCTAssertTrue("   ".isBlankString)
    }

    func test_isBlankString_newlinesOnly_returnsTrue() {
        XCTAssertTrue("\n\n".isBlankString)
    }

    func test_isBlankString_validString_returnsFalse() {
        XCTAssertFalse("Hello".isBlankString)
    }

    func test_isBlankString_mixedWhitespaceAndText_returnsFalse() {
        XCTAssertFalse("  Hi  ".isBlankString)
    }
}
