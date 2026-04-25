import Combine
import SwiftData
import XCTest
@testable import MoviesAppTask

final class PersistenceManagerMovieTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: PersistenceManager<CachedMovieEntity>!

    override func setUpWithError() throws {
        let schema = Schema([
            CachedGenreEntity.self,
            CachedMovieEntity.self,
            CachedSpokenLanguageEntity.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = PersistenceManager<CachedMovieEntity>(container: container)
    }

    override func tearDownWithError() throws {
        sut = nil
        container = nil
    }

    // MARK: - Helpers

    private func makeMovie(
        id: Int,
        title: String,
        popularity: Double = 50.0
    ) -> CachedMovieEntity {
        CachedMovieEntity(
            id: id,
            title: title,
            posterPath: "/\(id).jpg",
            popularity: popularity,
            genreIds: []
        )
    }

    // MARK: - Save & Fetch

    func test_save_singleMovie_canBeFetchedBack() throws {
        try awaitPublisher(sut.save(makeMovie(id: 1, title: "Inception")))

        let page = try awaitPublisher(sut.fetch())

        XCTAssertEqual(page.results.count, 1)
        XCTAssertEqual(page.results[0].title, "Inception")
    }

    func test_save_multipleMovies_allStoredAndFetched() throws {
        let movies = [
            makeMovie(id: 1, title: "Inception"),
            makeMovie(id: 2, title: "Interstellar"),
            makeMovie(id: 3, title: "Dunkirk"),
        ]
        try awaitPublisher(sut.save(movies))

        let page = try awaitPublisher(sut.fetch())

        XCTAssertEqual(page.results.count, 3)
        XCTAssertEqual(page.totalResults, 3)
    }

    // MARK: - Popularity Sort (mirrors repository usage)

    func test_fetch_sortedByPopularityDescending_returnsCorrectOrder() throws {
        let movies = [
            makeMovie(id: 1, title: "Low",    popularity: 20.0),
            makeMovie(id: 2, title: "High",   popularity: 95.0),
            makeMovie(id: 3, title: "Medium", popularity: 55.0),
        ]
        try awaitPublisher(sut.save(movies))

        let page = try awaitPublisher(
            sut.fetch(sortedBy: [SortDescriptor(\CachedMovieEntity.popularity, order: .reverse)])
        )

        XCTAssertEqual(page.results.map(\.title), ["High", "Medium", "Low"])
    }

    func test_fetch_sortedByPopularityAscending_returnsCorrectOrder() throws {
        let movies = [
            makeMovie(id: 1, title: "High",   popularity: 95.0),
            makeMovie(id: 2, title: "Low",    popularity: 20.0),
            makeMovie(id: 3, title: "Medium", popularity: 55.0),
        ]
        try awaitPublisher(sut.save(movies))

        let page = try awaitPublisher(
            sut.fetch(sortedBy: [SortDescriptor(\CachedMovieEntity.popularity)])
        )

        XCTAssertEqual(page.results.map(\.title), ["Low", "Medium", "High"])
    }

    // MARK: - Fetch by ID

    func test_fetchByID_existingMovie_returnsCorrectMovie() throws {
        let movie = makeMovie(id: 10, title: "The Dark Knight")
        try awaitPublisher(sut.save(movie))

        let fetched = try awaitPublisher(sut.fetch(byID: 10))

        XCTAssertEqual(fetched.id, 10)
        XCTAssertEqual(fetched.title, "The Dark Knight")
    }

    func test_fetchByID_nonExistingMovie_throwsError() {
        XCTAssertThrowsError(try awaitPublisher(sut.fetch(byID: 999))) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 404)
        }
    }

    // MARK: - Fetch by IDs

    func test_fetchByIDs_returnsOnlyMatchingMovies() throws {
        let movies = [
            makeMovie(id: 1, title: "Movie A"),
            makeMovie(id: 2, title: "Movie B"),
            makeMovie(id: 3, title: "Movie C"),
        ]
        try awaitPublisher(sut.save(movies))

        let results = try awaitPublisher(sut.fetch(byIDs: [1, 3]))

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.map(\.id).contains(1))
        XCTAssertTrue(results.map(\.id).contains(3))
    }

    // MARK: - Pagination

    func test_fetch_paginated_totalResultsReflectFullStore() throws {
        let movies = (1...10).map { makeMovie(id: $0, title: "Movie \($0)") }
        try awaitPublisher(sut.save(movies))

        let page = try awaitPublisher(sut.fetch(pageSize: 3, page: 0))

        XCTAssertEqual(page.results.count, 3)
        XCTAssertEqual(page.totalResults, 10)
    }

    func test_fetch_lastPage_containsRemainingItems() throws {
        // 10 items, page size 3 → last page (index 3) has 1 item
        let movies = (1...10).map { makeMovie(id: $0, title: "Movie \($0)") }
        try awaitPublisher(sut.save(movies))

        let page = try awaitPublisher(sut.fetch(pageSize: 3, page: 3))

        XCTAssertEqual(page.results.count, 1)
    }

    func test_fetch_totalPages_roundsUpCorrectly() throws {
        // 10 items / 3 per page = ceil(3.33) = 4 pages
        let movies = (1...10).map { makeMovie(id: $0, title: "Movie \($0)") }
        try awaitPublisher(sut.save(movies))

        let page = try awaitPublisher(sut.fetch(pageSize: 3, page: 0))

        XCTAssertEqual(page.totalPages, 4)
    }

    // MARK: - Delete

    func test_deleteAll_removesAllMovies() throws {
        let movies = [makeMovie(id: 1, title: "A"), makeMovie(id: 2, title: "B")]
        try awaitPublisher(sut.save(movies))

        try awaitPublisher(sut.deleteAll())

        let page = try awaitPublisher(sut.fetch())
        XCTAssertTrue(page.results.isEmpty)
    }

    func test_deleteAll_thenSaveNew_onlyNewMovieExists() throws {
        try awaitPublisher(sut.save(makeMovie(id: 1, title: "Old")))
        try awaitPublisher(sut.deleteAll())

        try awaitPublisher(sut.save(makeMovie(id: 2, title: "New")))

        let page = try awaitPublisher(sut.fetch())
        XCTAssertEqual(page.results.count, 1)
        XCTAssertEqual(page.results[0].title, "New")
    }
}

