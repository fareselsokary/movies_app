import Combine
import SwiftData
import XCTest
@testable import MoviesAppTask

final class PersistenceManagerGenreTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: PersistenceManager<CachedGenreEntity>!

    override func setUpWithError() throws {
        let schema = Schema([
            CachedGenreEntity.self,
            CachedMovieEntity.self,
            CachedSpokenLanguageEntity.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        sut = PersistenceManager<CachedGenreEntity>(container: container)
    }

    override func tearDownWithError() throws {
        sut = nil
        container = nil
    }

    // MARK: - Save

    func test_save_singleEntity_canBeFetchedBack() throws {
        try awaitPublisher(sut.save(CachedGenreEntity(id: 1, name: "Action")))

        let page = try awaitPublisher(sut.fetch())

        XCTAssertEqual(page.results.count, 1)
        XCTAssertEqual(page.results[0].id, 1)
        XCTAssertEqual(page.results[0].name, "Action")
    }

    func test_save_multipleEntities_allStoredAndFetched() throws {
        let genres = [
            CachedGenreEntity(id: 1, name: "Action"),
            CachedGenreEntity(id: 2, name: "Comedy"),
            CachedGenreEntity(id: 3, name: "Drama"),
        ]

        try awaitPublisher(sut.save(genres))

        let page = try awaitPublisher(sut.fetch())

        XCTAssertEqual(page.results.count, 3)
        XCTAssertEqual(page.totalResults, 3)
    }

    func test_save_emptyArray_storeRemainsEmpty() throws {
        try awaitPublisher(sut.save([]))

        let page = try awaitPublisher(sut.fetch())

        XCTAssertTrue(page.results.isEmpty)
    }

    // MARK: - Fetch

    func test_fetch_emptyStore_returnsEmptyResults() throws {
        let page = try awaitPublisher(sut.fetch())

        XCTAssertTrue(page.results.isEmpty)
        XCTAssertEqual(page.totalResults, 0)
    }

    func test_fetch_totalResults_matchesStoredCount() throws {
        let genres = [
            CachedGenreEntity(id: 1, name: "Action"),
            CachedGenreEntity(id: 2, name: "Comedy"),
        ]
        try awaitPublisher(sut.save(genres))

        let page = try awaitPublisher(sut.fetch())

        XCTAssertEqual(page.totalResults, 2)
    }

    func test_fetch_withSortDescriptor_returnsAlphabeticalOrder() throws {
        let genres = [
            CachedGenreEntity(id: 3, name: "Comedy"),
            CachedGenreEntity(id: 1, name: "Action"),
            CachedGenreEntity(id: 2, name: "Drama"),
        ]
        try awaitPublisher(sut.save(genres))

        let page = try awaitPublisher(
            sut.fetch(sortedBy: [SortDescriptor(\CachedGenreEntity.name)])
        )

        XCTAssertEqual(page.results.map(\.name), ["Action", "Comedy", "Drama"])
    }

    // MARK: - Fetch by ID

    func test_fetchByID_existingEntity_returnsCorrectEntity() throws {
        try awaitPublisher(sut.save(CachedGenreEntity(id: 42, name: "Thriller")))

        let entity = try awaitPublisher(sut.fetch(byID: 42))

        XCTAssertEqual(entity.id, 42)
        XCTAssertEqual(entity.name, "Thriller")
    }

    func test_fetchByID_nonExistingEntity_throwsError() throws {
        XCTAssertThrowsError(try awaitPublisher(sut.fetch(byID: 999))) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 404)
        }
    }

    // MARK: - Fetch by IDs

    func test_fetchByIDs_returnsMatchingSubset() throws {
        let genres = [
            CachedGenreEntity(id: 1, name: "Action"),
            CachedGenreEntity(id: 2, name: "Comedy"),
            CachedGenreEntity(id: 3, name: "Drama"),
        ]
        try awaitPublisher(sut.save(genres))

        let results = try awaitPublisher(sut.fetch(byIDs: [1, 3]))

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.map(\.id).contains(1))
        XCTAssertTrue(results.map(\.id).contains(3))
        XCTAssertFalse(results.map(\.id).contains(2))
    }

    func test_fetchByIDs_noMatches_returnsEmpty() throws {
        try awaitPublisher(sut.save(CachedGenreEntity(id: 1, name: "Action")))

        let results = try awaitPublisher(sut.fetch(byIDs: [99, 100]))

        XCTAssertTrue(results.isEmpty)
    }

    func test_fetchByIDs_emptyIDList_returnsEmpty() throws {
        try awaitPublisher(sut.save(CachedGenreEntity(id: 1, name: "Action")))

        let results = try awaitPublisher(sut.fetch(byIDs: []))

        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Pagination

    func test_fetch_withPagination_firstPage_returnsCorrectSlice() throws {
        let genres = (1...5).map { CachedGenreEntity(id: $0, name: "Genre \($0)") }
        try awaitPublisher(sut.save(genres))

        let page = try awaitPublisher(sut.fetch(pageSize: 2, page: 0))

        XCTAssertEqual(page.results.count, 2)
        XCTAssertEqual(page.totalResults, 5)
        XCTAssertEqual(page.page, 0)
    }

    func test_fetch_withPagination_secondPage_returnsNextSlice() throws {
        let genres = (1...5).map { CachedGenreEntity(id: $0, name: "Genre \($0)") }
        try awaitPublisher(sut.save(genres))

        let page = try awaitPublisher(sut.fetch(pageSize: 2, page: 1))

        XCTAssertEqual(page.results.count, 2)
        XCTAssertEqual(page.page, 1)
    }

    func test_fetch_totalPages_calculatedCorrectly() throws {
        // 5 items / 2 per page = ceil(2.5) = 3 pages
        let genres = (1...5).map { CachedGenreEntity(id: $0, name: "Genre \($0)") }
        try awaitPublisher(sut.save(genres))

        let page = try awaitPublisher(sut.fetch(pageSize: 2, page: 0))

        XCTAssertEqual(page.totalPages, 3)
    }

    func test_fetch_exactDivision_totalPagesIsCorrect() throws {
        // 4 items / 2 per page = 2 pages exactly
        let genres = (1...4).map { CachedGenreEntity(id: $0, name: "Genre \($0)") }
        try awaitPublisher(sut.save(genres))

        let page = try awaitPublisher(sut.fetch(pageSize: 2, page: 0))

        XCTAssertEqual(page.totalPages, 2)
    }

    func test_fetch_withoutPagination_returnsAllResults() throws {
        let genres = (1...5).map { CachedGenreEntity(id: $0, name: "Genre \($0)") }
        try awaitPublisher(sut.save(genres))

        let page = try awaitPublisher(sut.fetch())

        XCTAssertEqual(page.results.count, 5)
        XCTAssertEqual(page.totalResults, 5)
    }

    // MARK: - Delete

    func test_deleteAll_removesAllEntities() throws {
        let genres = [
            CachedGenreEntity(id: 1, name: "Action"),
            CachedGenreEntity(id: 2, name: "Comedy"),
        ]
        try awaitPublisher(sut.save(genres))

        try awaitPublisher(sut.deleteAll())

        let page = try awaitPublisher(sut.fetch())
        XCTAssertTrue(page.results.isEmpty)
    }

    func test_deleteAll_emptyStore_doesNotFail() throws {
        XCTAssertNoThrow(try awaitPublisher(sut.deleteAll()))
    }

    func test_save_afterDeleteAll_storesNewEntities() throws {
        try awaitPublisher(sut.save(CachedGenreEntity(id: 1, name: "Action")))
        try awaitPublisher(sut.deleteAll())

        try awaitPublisher(sut.save(CachedGenreEntity(id: 2, name: "Comedy")))

        let page = try awaitPublisher(sut.fetch())
        XCTAssertEqual(page.results.count, 1)
        XCTAssertEqual(page.results[0].name, "Comedy")
    }
}

