import XCTest
@testable import MoviesAppTask

final class DoubleDurationTests: XCTestCase {

    func test_formattedHoursAndMinutes_returnsNonEmptyString() {
        XCTAssertFalse((100.0).formattedHoursAndMinutes.isEmpty)
    }

    func test_formattedHoursAndMinutes_zero_returnsValidString() {
        XCTAssertFalse((0.0).formattedHoursAndMinutes.isEmpty)
    }

    func test_formattedHoursAndMinutes_exactHour_containsHour() {
        // 60 minutes = 1 hour
        let result = (60.0).formattedHoursAndMinutes.lowercased()
        XCTAssertTrue(result.contains("hour"))
    }

    func test_formattedHoursAndMinutes_lessThanHour_doesNotContainHour() {
        // 30 minutes
        let result = (30.0).formattedHoursAndMinutes.lowercased()
        XCTAssertFalse(result.contains("hour"))
    }

    func test_formattedHoursAndMinutes_ninetyMinutes_containsBothUnits() {
        // 90 minutes = 1 hour 30 minutes
        let result = (90.0).formattedHoursAndMinutes.lowercased()
        XCTAssertTrue(result.contains("hour"))
        XCTAssertTrue(result.contains("minute"))
    }
}
