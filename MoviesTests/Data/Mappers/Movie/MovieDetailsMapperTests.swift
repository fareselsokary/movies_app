@testable import MoviesAppTask
import XCTest

final class MovieDetailsMapperTests: XCTestCase {
    private let testDate = DateFormatter.yyyyMMdd.date(from: "2023-07-21")!

    private var sampleGenreResponses: [GenreResponse] {
        [GenreResponse(id: 28, name: "Action"), GenreResponse(id: 12, name: "Adventure")]
    }

    // MARK: - MovieDetailResponse → MovieDetail

    func test_toDomain_fromMovieDetailResponse_mapsScalarFields() {
        let response = MovieDetailResponse(
            id: 10, title: "Epic Film", overview: "An epic story",
            posterPath: "/poster.jpg", backdropPath: "/backdrop.jpg",
            releaseDate: testDate, genres: sampleGenreResponses,
            homepage: "https://epicfilm.com", budget: 100_000_000,
            revenue: 500_000_000, spokenLanguages: [],
            status: "Released", runtime: 120
        )

        let detail = response.toDomain()

        XCTAssertEqual(detail.id, 10)
        XCTAssertEqual(detail.title, "Epic Film")
        XCTAssertEqual(detail.overview, "An epic story")
        XCTAssertEqual(detail.posterPath, "/poster.jpg")
        XCTAssertEqual(detail.backdropPath, "/backdrop.jpg")
        XCTAssertEqual(detail.releaseDate, testDate)
        XCTAssertEqual(detail.homepage, "https://epicfilm.com")
        XCTAssertEqual(detail.budget, 100_000_000)
        XCTAssertEqual(detail.revenue, 500_000_000)
        XCTAssertEqual(detail.status, "Released")
        XCTAssertEqual(detail.runtime, 120)
    }

    func test_toDomain_fromMovieDetailResponse_mapsGenres() {
        let response = MovieDetailResponse(
            id: 1, title: "", overview: "", posterPath: "", backdropPath: "",
            releaseDate: nil, genres: sampleGenreResponses,
            homepage: nil, budget: nil, revenue: nil,
            spokenLanguages: [], status: nil, runtime: nil
        )

        let detail = response.toDomain()

        XCTAssertEqual(detail.genres.count, 2)
        XCTAssertEqual(detail.genres[0].id, 28)
        XCTAssertEqual(detail.genres[0].name, "Action")
        XCTAssertEqual(detail.genres[1].id, 12)
    }

    func test_toDomain_fromMovieDetailResponse_mapsSpokenLanguages() {
        let langResponse = SpokenLanguageResponse(iso6391: "en", name: "English")
        let response = MovieDetailResponse(
            id: 1, title: "", overview: "", posterPath: "", backdropPath: "",
            releaseDate: nil, genres: [],
            homepage: nil, budget: nil, revenue: nil,
            spokenLanguages: [langResponse], status: nil, runtime: nil
        )

        let detail = response.toDomain()

        XCTAssertEqual(detail.spokenLanguages.count, 1)
        XCTAssertEqual(detail.spokenLanguages[0].iso6391, "en")
        XCTAssertEqual(detail.spokenLanguages[0].name, "English")
    }

    // MARK: - MovieDetail → CachedMovieEntity

    func test_toEntity_fromMovieDetail_mapsAllFields() {
        let detail = MovieDetail(
            id: 20, title: "Cached Detail", overview: "Overview text",
            posterPath: "/p.jpg", backdropPath: "/b.jpg", releaseDate: testDate,
            genres: [Genre(id: 28, name: "Action")],
            homepage: "https://test.com", budget: 50_000_000, revenue: 200_000_000,
            spokenLanguages: [SpokenLanguage(iso6391: "en", name: "English")],
            status: "Released", runtime: 90
        )

        let entity = detail.toEntity()

        XCTAssertEqual(entity.id, 20)
        XCTAssertEqual(entity.title, "Cached Detail")
        XCTAssertEqual(entity.overview, "Overview text")
        XCTAssertEqual(entity.posterPath, "/p.jpg")
        XCTAssertEqual(entity.backdropPath, "/b.jpg")
        XCTAssertEqual(entity.releaseDate, testDate)
        XCTAssertEqual(entity.homepage, "https://test.com")
        XCTAssertEqual(entity.budget, 50_000_000)
        XCTAssertEqual(entity.revenue, 200_000_000)
        XCTAssertEqual(entity.status, "Released")
        XCTAssertEqual(entity.runtime, 90)
        XCTAssertEqual(entity.genreIds, [28])
        XCTAssertEqual(entity.spokenLanguages.count, 1)
    }

    // MARK: - CachedMovieEntity → MovieDetail

    func test_toDomain_fromCachedMovieEntity_withGenres_mapsAllFields() {
        let entity = CachedMovieEntity(
            id: 30, title: "From Cached Detail", posterPath: "/pp.jpg",
            releaseDate: testDate, overview: "Cached overview",
            backdropPath: "/bb.jpg", homepage: "https://cached.com",
            budget: 70_000_000, revenue: 300_000_000,
            spokenLanguages: [CachedSpokenLanguageEntity(iso6391: "fr", name: "French")],
            status: "Released", runtime: 100, genreIds: [28]
        )
        let cachedGenres = [CachedGenreEntity(id: 28, name: "Action")]

        let detail = entity.toDomain(genres: cachedGenres)

        XCTAssertEqual(detail.id, 30)
        XCTAssertEqual(detail.title, "From Cached Detail")
        XCTAssertEqual(detail.overview, "Cached overview")
        XCTAssertEqual(detail.backdropPath, "/bb.jpg")
        XCTAssertEqual(detail.genres.count, 1)
        XCTAssertEqual(detail.genres[0].name, "Action")
        XCTAssertEqual(detail.spokenLanguages.count, 1)
        XCTAssertEqual(detail.spokenLanguages[0].iso6391, "fr")
    }

    func test_toDomain_fromCachedMovieEntity_nilOverview_defaultsToEmpty() {
        let entity = CachedMovieEntity(id: 1, title: "T", posterPath: "", overview: nil, genreIds: [])
        let detail = entity.toDomain(genres: [])
        XCTAssertEqual(detail.overview, "")
    }

    func test_toDomain_fromCachedMovieEntity_nilBackdropPath_defaultsToEmpty() {
        let entity = CachedMovieEntity(id: 1, title: "T", posterPath: "", backdropPath: nil, genreIds: [])
        let detail = entity.toDomain(genres: [])
        XCTAssertEqual(detail.backdropPath, "")
    }
}
