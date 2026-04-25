import XCTest
@testable import MoviesAppTask

final class DateFormatterExtensionTests: XCTestCase {

    func test_yyyyMMdd_parsesValidDate() {
        let date = DateFormatter.yyyyMMdd.date(from: "2024-06-15")
        XCTAssertNotNil(date)
    }

    func test_yyyyMMdd_parsedDateHasCorrectComponents() {
        let date = DateFormatter.yyyyMMdd.date(from: "2024-06-15")!
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        XCTAssertEqual(calendar.component(.year, from: date), 2024)
        XCTAssertEqual(calendar.component(.month, from: date), 6)
        XCTAssertEqual(calendar.component(.day, from: date), 15)
    }

    func test_yyyyMMdd_returnsNilForWrongFormat() {
        let date = DateFormatter.yyyyMMdd.date(from: "15-06-2024")
        XCTAssertNil(date)
    }

    func test_yyyyMMdd_returnsNilForEmptyString() {
        let date = DateFormatter.yyyyMMdd.date(from: "")
        XCTAssertNil(date)
    }

    func test_yyyyMMdd_roundTrip_preservesDate() {
        let original = "2023-01-01"
        let date = DateFormatter.yyyyMMdd.date(from: original)!
        let formatted = DateFormatter.yyyyMMdd.string(from: date)
        XCTAssertEqual(formatted, original)
    }

    func test_yyyyMMdd_usesUTCTimezone() {
        XCTAssertEqual(DateFormatter.yyyyMMdd.timeZone, TimeZone(secondsFromGMT: 0))
    }
}
