import Combine
@testable import MoviesAppTask
import XCTest

final class HomeViewModelTests: XCTestCase {
    private var mockUseCase: MockHomeUseCase!
    private var mockNavigator: MockNavigator!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockUseCase = MockHomeUseCase()
        mockNavigator = MockNavigator()
        // Default quiet results so init completes without hanging
        mockUseCase.trendingMoviesResult = Just(emptyPage)
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        mockUseCase.genresResult = Just([])
            .setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
        mockUseCase = nil
        mockNavigator = nil
    }

    // MARK: - Helpers

    private var emptyPage: PaginatedModel<Movie> {
        PaginatedModel(page: 1, results: [], totalPages: 1, totalResults: 0)
    }

    private func makePage(_ movies: [Movie], totalPages: Int = 1) -> PaginatedModel<Movie> {
        PaginatedModel(page: 1, results: movies, totalPages: totalPages, totalResults: movies.count)
    }

    private func makeMovie(id: Int, title: String, genreIds: [Int] = []) -> Movie {
        Movie(id: id, title: title, posterPath: "", releaseDate: nil, genreIds: genreIds, popularity: 50.0)
    }

    private func makeSUT() -> HomeViewModel {
        HomeViewModel(homeUseCase: mockUseCase, navigator: mockNavigator)
    }

    // MARK: - Init

    func test_init_callsUseCaseForMovies() {
        _ = makeSUT()
        waitForMainQueue()
        XCTAssertGreaterThanOrEqual(mockUseCase.fetchTrendingCallCount, 1)
    }

    func test_init_callsUseCaseForGenres() {
        _ = makeSUT()
        waitForMainQueue()
        XCTAssertGreaterThanOrEqual(mockUseCase.fetchGenresCallCount, 1)
    }

    func test_init_requestsPageOne() {
        _ = makeSUT()
        waitForMainQueue()
        XCTAssertEqual(mockUseCase.lastRequestedPage, 1)
    }

    // MARK: - Genres

    func test_loadGenres_onSuccess_populatesGenres() throws {
        let genres = [Genre(id: 28, name: "Action"), Genre(id: 12, name: "Adventure")]
        mockUseCase.genresResult = Just(genres)
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        // genres has no intermediate emission — dropFirst() safely skips the initial []
        try waitForNextValue(in: sut.$genres)

        XCTAssertEqual(sut.genres.count, 2)
        XCTAssertEqual(sut.genres.first?.name, "Action")
    }

    func test_loadGenres_onFailure_genresRemainsEmpty() {
        mockUseCase.genresResult = Fail(error: NSError(domain: "Test", code: -1))
            .eraseToAnyPublisher()

        let sut = makeSUT()
        waitForMainQueue()

        XCTAssertTrue(sut.genres.isEmpty)
    }

    // MARK: - Movie Loading

    func test_loadMovies_onSuccess_populatesFilteredMovies() throws {
        let movies = [makeMovie(id: 1, title: "Inception")]
        mockUseCase.trendingMoviesResult = Just(makePage(movies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        // filteredMovies fires [] from the initial CombineLatest3 before movies arrive,
        // so we wait for the specific non-empty state rather than "next emission".
        try waitForValue(in: sut.$filteredMovies) { $0.count == 1 }

        XCTAssertEqual(sut.filteredMovies.first?.title, "Inception")
    }

    func test_loadMovies_onFailure_filteredMoviesRemainsEmpty() {
        mockUseCase.trendingMoviesResult = Fail(error: NSError(domain: "Test", code: -1))
            .eraseToAnyPublisher()

        let sut = makeSUT()
        waitForMainQueue()

        XCTAssertTrue(sut.filteredMovies.isEmpty)
    }

    func test_loadMovies_deduplicatesDuplicateIds() throws {
        let movies = [
            makeMovie(id: 1, title: "Inception"),
            makeMovie(id: 1, title: "Inception"),
        ]
        mockUseCase.trendingMoviesResult = Just(makePage(movies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { !$0.isEmpty }

        XCTAssertEqual(sut.filteredMovies.count, 1)
    }

    // MARK: - Search Filter

    func test_searchText_filtersMoviesByTitle() throws {
        let movies = [
            makeMovie(id: 1, title: "Inception"),
            makeMovie(id: 2, title: "Interstellar"),
            makeMovie(id: 3, title: "Dunkirk"),
        ]
        mockUseCase.trendingMoviesResult = Just(makePage(movies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { $0.count == 3 }

        sut.searchText = "Inter"
        try waitForValue(in: sut.$filteredMovies) { $0.count == 1 }

        XCTAssertEqual(sut.filteredMovies.first?.title, "Interstellar")
    }

    func test_searchText_isCaseInsensitive() throws {
        let movies = [makeMovie(id: 1, title: "Inception"), makeMovie(id: 2, title: "Dunkirk")]
        mockUseCase.trendingMoviesResult = Just(makePage(movies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { $0.count == 2 }

        sut.searchText = "inception"
        try waitForValue(in: sut.$filteredMovies) { $0.count == 1 }

        XCTAssertEqual(sut.filteredMovies.first?.title, "Inception")
    }

    func test_searchText_blankText_showsAllMovies() throws {
        let movies = [makeMovie(id: 1, title: "Inception"), makeMovie(id: 2, title: "Dunkirk")]
        mockUseCase.trendingMoviesResult = Just(makePage(movies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { $0.count == 2 }

        sut.searchText = "zzz"
        try waitForValue(in: sut.$filteredMovies) { $0.isEmpty }

        sut.searchText = ""
        try waitForValue(in: sut.$filteredMovies) { $0.count == 2 }

        XCTAssertEqual(sut.filteredMovies.count, 2)
    }

    // MARK: - Genre Filter

    func test_selectedGenreId_filtersMoviesByGenre() throws {
        let movies = [
            makeMovie(id: 1, title: "Action Film", genreIds: [28]),
            makeMovie(id: 2, title: "Comedy Film", genreIds: [35]),
        ]
        mockUseCase.trendingMoviesResult = Just(makePage(movies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { $0.count == 2 }

        sut.selectedGenreId = 28
        try waitForValue(in: sut.$filteredMovies) { $0.count == 1 }

        XCTAssertEqual(sut.filteredMovies.first?.title, "Action Film")
    }

    func test_selectedGenreId_nil_showsAllMovies() throws {
        let movies = [
            makeMovie(id: 1, title: "Action Film", genreIds: [28]),
            makeMovie(id: 2, title: "Comedy Film", genreIds: [35]),
        ]
        mockUseCase.trendingMoviesResult = Just(makePage(movies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { $0.count == 2 }

        sut.selectedGenreId = 28
        try waitForValue(in: sut.$filteredMovies) { $0.count == 1 }

        sut.selectedGenreId = nil
        try waitForValue(in: sut.$filteredMovies) { $0.count == 2 }

        XCTAssertEqual(sut.filteredMovies.count, 2)
    }

    func test_combinedFilter_searchAndGenre_appliesBoth() throws {
        let movies = [
            makeMovie(id: 1, title: "Action Hero",   genreIds: [28]),
            makeMovie(id: 2, title: "Action Comedy", genreIds: [35]),
            makeMovie(id: 3, title: "Drama",         genreIds: [28]),
        ]
        mockUseCase.trendingMoviesResult = Just(makePage(movies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { $0.count == 3 }

        sut.selectedGenreId = 28
        try waitForValue(in: sut.$filteredMovies) { $0.count == 2 }  // Hero + Drama

        sut.searchText = "Action"
        try waitForValue(in: sut.$filteredMovies) { $0.count == 1 }  // only Hero

        XCTAssertEqual(sut.filteredMovies.first?.title, "Action Hero")
    }

    // MARK: - Refresh

    func test_refresh_callsUseCaseWithShouldResetCacheTrue() {
        let sut = makeSUT()
        waitForMainQueue()

        let callCountBefore = mockUseCase.fetchTrendingCallCount
        sut.refresh()
        waitForMainQueue()

        XCTAssertGreaterThan(mockUseCase.fetchTrendingCallCount, callCountBefore)
        XCTAssertEqual(mockUseCase.lastShouldResetCache, true)
    }

    func test_refresh_resetsSelectedGenreId() {
        let sut = makeSUT()
        waitForMainQueue()

        sut.selectedGenreId = 28
        sut.refresh()

        XCTAssertNil(sut.selectedGenreId)
    }

    func test_refresh_replacesMoviesInsteadOfAppending() throws {
        let initialMovies  = [makeMovie(id: 1, title: "Old Movie")]
        let refreshedMovies = [makeMovie(id: 2, title: "New Movie")]

        mockUseCase.trendingMoviesResult = Just(makePage(initialMovies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { !$0.isEmpty }

        mockUseCase.trendingMoviesResult = Just(makePage(refreshedMovies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        sut.refresh()
        try waitForValue(in: sut.$filteredMovies) { $0.first?.title == "New Movie" }

        XCTAssertEqual(sut.filteredMovies.count, 1)
        XCTAssertEqual(sut.filteredMovies.first?.title, "New Movie")
    }

    // MARK: - Pagination

    func test_fetchNextPage_whenLastMovieVisible_triggersNextPage() throws {
        let movies = [makeMovie(id: 1, title: "Movie A"), makeMovie(id: 2, title: "Movie B")]
        mockUseCase.trendingMoviesResult = Just(makePage(movies, totalPages: 3))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        // Ensure filteredMovies is populated so the last-item check works
        try waitForValue(in: sut.$filteredMovies) { $0.count == 2 }

        let callCountBefore = mockUseCase.fetchTrendingCallCount
        sut.fetchNextPage(current: movies.last!)
        waitForMainQueue()

        XCTAssertGreaterThan(mockUseCase.fetchTrendingCallCount, callCountBefore)
    }

    func test_fetchNextPage_whenNotLastMovie_doesNotTriggerLoad() throws {
        let movies = [makeMovie(id: 1, title: "Movie A"), makeMovie(id: 2, title: "Movie B")]
        mockUseCase.trendingMoviesResult = Just(makePage(movies, totalPages: 3))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { $0.count == 2 }

        let callCountBefore = mockUseCase.fetchTrendingCallCount
        sut.fetchNextPage(current: movies.first!) // not the last
        waitForMainQueue()

        XCTAssertEqual(mockUseCase.fetchTrendingCallCount, callCountBefore)
    }

    // MARK: - Navigation

    func test_didSelectMovie_callsNavigatorWithCorrectId() {
        let sut = makeSUT()
        sut.didSelectMovie(99)

        XCTAssertEqual(mockNavigator.showMovieDetailCallCount, 1)
        XCTAssertEqual(mockNavigator.lastMovieDetailId, 99)
    }

    // MARK: - Computed: message

    func test_message_withSearchText_includesSearchTerm() throws {
        let movies = [makeMovie(id: 1, title: "Inception")]
        mockUseCase.trendingMoviesResult = Just(makePage(movies))
            .setFailureType(to: Error.self).eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForValue(in: sut.$filteredMovies) { !$0.isEmpty }

        sut.searchText = "xyz"
        try waitForValue(in: sut.$filteredMovies) { $0.isEmpty }

        XCTAssertTrue(sut.message.contains("xyz"))
    }

    func test_message_withNoMoviesAndNoSearch_returnsDefaultMessage() {
        let sut = makeSUT()
        waitForMainQueue()

        XCTAssertEqual(sut.message, "No movies found")
    }

    // MARK: - Computed: isLoading

    func test_isLoading_afterSuccessfulFirstLoad_isFalse() {
        let sut = makeSUT()
        waitForMainQueue()

        XCTAssertFalse(sut.isLoading)
    }
}
