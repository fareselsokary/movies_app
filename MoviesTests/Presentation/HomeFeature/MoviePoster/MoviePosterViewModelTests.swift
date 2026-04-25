@testable import MoviesAppTask
import XCTest

final class MoviePosterViewModelTests: XCTestCase {
    private let testDate = DateFormatter.yyyyMMdd.date(from: "2010-07-16")!

    // MARK: - Init

    func test_init_setsAllProperties() {
        let sut = MoviePosterViewModel(id: 1, imageURL: "/poster.jpg", title: "Inception", releaseData: testDate)

        XCTAssertEqual(sut.id, 1)
        XCTAssertEqual(sut.imageURL, "/poster.jpg")
        XCTAssertEqual(sut.title, "Inception")
    }

    func test_init_withNilImageURL_imageURLIsNil() {
        let sut = MoviePosterViewModel(id: 1, imageURL: nil, title: "Inception", releaseData: nil)

        XCTAssertNil(sut.imageURL)
    }

    // MARK: - Release Date Formatting

    func test_init_withValidReleaseDate_formatsToYYYYMMDD() {
        let sut = MoviePosterViewModel(id: 1, imageURL: nil, title: "", releaseData: testDate)

        XCTAssertEqual(sut.releaseData, "2010-07-16")
    }

    func test_init_withNilReleaseDate_releaseDateIsNil() {
        let sut = MoviePosterViewModel(id: 1, imageURL: nil, title: "", releaseData: nil)

        XCTAssertNil(sut.releaseData)
    }

    func test_init_differentDates_formatCorrectly() {
        let date2024 = DateFormatter.yyyyMMdd.date(from: "2024-01-01")!
        let sut = MoviePosterViewModel(id: 1, imageURL: nil, title: "", releaseData: date2024)

        XCTAssertEqual(sut.releaseData, "2024-01-01")
    }
}
