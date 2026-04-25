@testable import MoviesAppTask
import XCTest

final class MovieModelMapperTests: XCTestCase {
    private let testDate = DateFormatter.yyyyMMdd.date(from: "2024-01-15")!

    // MARK: - MovieResponse → Movie

    func test_toDomain_fromMovieResponse_mapsAllFields() {
        let response = MovieResponse(
            id: 1,
            title: "Test Movie",
            posterPath: "/poster.jpg",
            releaseDate: testDate,
            genreIds: [28, 12],
            popularity: 75.5
        )

        let movie = response.toDomain()

        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.posterPath, "/poster.jpg")
        XCTAssertEqual(movie.releaseDate, testDate)
        XCTAssertEqual(movie.genreIds, [28, 12])
        XCTAssertEqual(movie.popularity, 75.5)
    }

    func test_toDomain_fromMovieResponse_nilReleaseDate_preserved() {
        let response = MovieResponse(id: 1, title: "No Date", posterPath: "", releaseDate: nil, genreIds: [], popularity: 0)
        let movie = response.toDomain()
        XCTAssertNil(movie.releaseDate)
    }

    // MARK: - Movie → CachedMovieEntity

    func test_toEntity_fromMovie_mapsAllFields() {
        let movie = Movie(id: 2, title: "Cache Me", posterPath: "/cache.jpg", releaseDate: testDate, genreIds: [10], popularity: 50.0)
        let entity = movie.toEntity()

        XCTAssertEqual(entity.id, 2)
        XCTAssertEqual(entity.title, "Cache Me")
        XCTAssertEqual(entity.posterPath, "/cache.jpg")
        XCTAssertEqual(entity.releaseDate, testDate)
        XCTAssertEqual(entity.genreIds, [10])
        XCTAssertEqual(entity.popularity, 50.0)
    }

    // MARK: - CachedMovieEntity → Movie

    func test_toDomain_fromCachedMovieEntity_mapsAllFields() {
        let entity = CachedMovieEntity(
            id: 3,
            title: "From Cache",
            posterPath: "/cached.jpg",
            releaseDate: testDate,
            popularity: 88.8,
            genreIds: [18, 35]
        )

        let movie = entity.toDomain()

        XCTAssertEqual(movie.id, 3)
        XCTAssertEqual(movie.title, "From Cache")
        XCTAssertEqual(movie.posterPath, "/cached.jpg")
        XCTAssertEqual(movie.releaseDate, testDate)
        XCTAssertEqual(movie.genreIds, [18, 35])
        XCTAssertEqual(movie.popularity, 88.8)
    }

    func test_toDomain_fromCachedMovieEntity_nilPopularity_defaultsToZero() {
        let entity = CachedMovieEntity(id: 4, title: "No Pop", posterPath: "", popularity: nil, genreIds: [])
        let movie = entity.toDomain()
        XCTAssertEqual(movie.popularity, 0)
    }

    // MARK: - Round-trip

    func test_roundTrip_movieResponseToEntityToDomain_preservesData() {
        let response = MovieResponse(id: 5, title: "Round Trip", posterPath: "/rt.jpg", releaseDate: testDate, genreIds: [1, 2], popularity: 42.0)
        let restored = response.toDomain().toEntity().toDomain()

        XCTAssertEqual(restored.id, response.id)
        XCTAssertEqual(restored.title, response.title)
        XCTAssertEqual(restored.posterPath, response.posterPath)
        XCTAssertEqual(restored.genreIds, response.genreIds)
        XCTAssertEqual(restored.popularity, response.popularity)
    }
}
