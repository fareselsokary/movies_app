import XCTest
@testable import MoviesAppTask

final class DateExtensionTests: XCTestCase {

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }

    func test_formattedYear_returnsCorrectYear() {
        let date = makeDate(year: 2024, month: 6, day: 15)
        XCTAssertEqual(date.formattedYear(), "2024")
    }

    func test_formattedYear_earlyYear_returnsCorrectYear() {
        let date = makeDate(year: 1990, month: 1, day: 1)
        XCTAssertEqual(date.formattedYear(), "1990")
    }

    func test_formattedYear_returnsExactlyFourCharacters() {
        let year = makeDate(year: 2000, month: 7, day: 20).formattedYear()
        XCTAssertEqual(year.count, 4)
    }

    func test_formattedYear_returnsStringContainingOnlyDigits() {
        let year = makeDate(year: 2023, month: 3, day: 10).formattedYear()
        XCTAssertTrue(year.allSatisfy(\.isNumber))
    }
}
