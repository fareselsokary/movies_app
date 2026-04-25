@testable import MoviesAppTask
import XCTest

final class DoubleNumberFormatterTests: XCTestCase {
    func test_formattedPrice_default_appendsCurrencySymbol() {
        let result = 1000.0.formattedPrice()
        XCTAssertTrue(result.hasSuffix("$"))
    }

    func test_formattedPrice_currencyPrefix_true_prependsSymbol() {
        let result = 1000.0.formattedPrice(currencyPrefix: true)
        XCTAssertTrue(result.hasPrefix("$"))
    }

    func test_formattedPrice_customCurrency_usesProvidedSymbol() {
        let result = 500.0.formattedPrice(currency: "€", currencyPrefix: true)
        XCTAssertTrue(result.hasPrefix("€"))
    }

    func test_formattedPrice_maximumFractionDigits_includesDecimal() {
        let result = 1000.5.formattedPrice(maximumFractionDigits: 2)
        XCTAssertTrue(result.contains("5"))
    }

    func test_formattedPrice_zero_returnsNonEmptyString() {
        XCTAssertFalse(0.0.formattedPrice().isEmpty)
    }
}
