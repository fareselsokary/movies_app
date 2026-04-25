import XCTest
@testable import MoviesAppTask

final class LoggerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Logger.isLoggingEnabled = true
    }

    override func tearDown() {
        super.tearDown()
        Logger.isLoggingEnabled = true
    }

    func test_isLoggingEnabled_defaultIsTrue() {
        XCTAssertTrue(Logger.isLoggingEnabled)
    }

    func test_isLoggingEnabled_canBeSetToFalse() {
        Logger.isLoggingEnabled = false
        XCTAssertFalse(Logger.isLoggingEnabled)
    }

    func test_log_doesNotCrashWhenEnabled() {
        Logger.isLoggingEnabled = true
        Logger.log("test message")
    }

    func test_log_doesNotCrashWhenDisabled() {
        Logger.isLoggingEnabled = false
        Logger.log("test message")
    }

    func test_verbose_doesNotCrash() {
        Logger.verbose("verbose message")
    }

    func test_error_doesNotCrash() {
        Logger.error("error message")
    }

    func test_logLevel_verbose_rawValue() {
        XCTAssertEqual(Logger.LogLevel.verbose.rawValue, "VERBOSE")
    }

    func test_logLevel_error_rawValue() {
        XCTAssertEqual(Logger.LogLevel.error.rawValue, "ERROR")
    }
}
