import Combine
@testable import MoviesAppTask
import XCTest

final class MovieDetailViewModelTests: XCTestCase {
    private var mockUseCase: MockMovieDetailUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockUseCase = MockMovieDetailUseCase()
    }

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
        mockUseCase = nil
    }

    // MARK: - Helpers

    private func makeSUT(movieId: Int = 1) -> MovieDetailViewModel {
        MovieDetailViewModel(movieId: movieId, movieDetailUseCase: mockUseCase)
    }

    private func makeDetail(
        id: Int = 1,
        title: String = "Test Movie",
        overview: String = "Overview",
        posterPath: String = "/poster.jpg",
        backdropPath: String = "/backdrop.jpg",
        releaseDate: Date? = DateFormatter.yyyyMMdd.date(from: "2010-07-16"),
        genres: [Genre] = [Genre(id: 28, name: "Action")],
        homepage: String? = "https://example.com",
        budget: Double? = 160_000_000,
        revenue: Double? = 825_000_000,
        spokenLanguages: [SpokenLanguage] = [SpokenLanguage(iso6391: "en", name: "English")],
        status: String? = "Released",
        runtime: Double? = 148
    ) -> MovieDetail {
        MovieDetail(
            id: id, title: title, overview: overview,
            posterPath: posterPath, backdropPath: backdropPath,
            releaseDate: releaseDate, genres: genres,
            homepage: homepage, budget: budget, revenue: revenue,
            spokenLanguages: spokenLanguages, status: status, runtime: runtime
        )
    }

    // MARK: - Init / Loading

    func test_init_callsUseCaseWithCorrectMovieId() {
        mockUseCase.movieDetailResult = Empty().eraseToAnyPublisher()
        _ = makeSUT(movieId: 42)

        XCTAssertEqual(mockUseCase.lastFetchedMovieId, 42)
    }

    func test_init_setsIsLoadingTrue_beforeResultArrives() {
        mockUseCase.movieDetailResult = Empty().eraseToAnyPublisher()
        let sut = makeSUT()

        XCTAssertTrue(sut.isLoading)
    }

    func test_isLoading_setsFalse_onSuccess() throws {
        mockUseCase.movieDetailResult = Just(makeDetail())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForNextValue(in: sut.$isLoading)

        XCTAssertFalse(sut.isLoading)
    }

    func test_isLoading_setsFalse_onFailure() throws {
        mockUseCase.movieDetailResult = Fail(error: NSError(domain: "Test", code: -1))
            .eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForNextValue(in: sut.$isLoading)

        XCTAssertFalse(sut.isLoading)
    }

    func test_movieDetails_populatedOnSuccess() throws {
        let detail = makeDetail(title: "Inception")
        mockUseCase.movieDetailResult = Just(detail)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)

        XCTAssertEqual(sut.movieDetails?.title, "Inception")
    }

    func test_movieDetails_remainsNil_onFailure() throws {
        mockUseCase.movieDetailResult = Fail(error: NSError(domain: "Test", code: -1))
            .eraseToAnyPublisher()

        let sut = makeSUT()
        try waitForNextValue(in: sut.$isLoading)

        XCTAssertNil(sut.movieDetails)
    }

    func test_loadMovieDetails_guardsPreventsDoubleCall() {
        mockUseCase.movieDetailResult = Empty().eraseToAnyPublisher()
        let sut = makeSUT()

        sut.loadMovieDetails() // already loading — guard fires

        XCTAssertEqual(mockUseCase.fetchCallCount, 1)
    }

    // MARK: - Computed Properties (nil state)

    func test_headerImage_whenNilDetails_returnsEmpty() {
        mockUseCase.movieDetailResult = Empty().eraseToAnyPublisher()
        let sut = makeSUT()
        XCTAssertEqual(sut.headerImage, "")
    }

    func test_posterImage_whenNilDetails_returnsEmpty() {
        mockUseCase.movieDetailResult = Empty().eraseToAnyPublisher()
        let sut = makeSUT()
        XCTAssertEqual(sut.posterImage, "")
    }

    func test_title_whenNilDetails_returnsEmpty() {
        mockUseCase.movieDetailResult = Empty().eraseToAnyPublisher()
        let sut = makeSUT()
        XCTAssertEqual(sut.title, "")
    }

    func test_genres_whenNilDetails_returnsEmpty() {
        mockUseCase.movieDetailResult = Empty().eraseToAnyPublisher()
        let sut = makeSUT()
        XCTAssertEqual(sut.genres, "")
    }

    func test_duration_whenNilRuntime_returnsEmpty() {
        mockUseCase.movieDetailResult = Empty().eraseToAnyPublisher()
        let sut = makeSUT()
        XCTAssertEqual(sut.duration, "")
    }

    // MARK: - Computed Properties (loaded state)

    func test_headerImage_returnsBackdropPath() throws {
        mockUseCase.movieDetailResult = Just(makeDetail(backdropPath: "/backdrop.jpg"))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertEqual(sut.headerImage, "/backdrop.jpg")
    }

    func test_posterImage_returnsPosterPath() throws {
        mockUseCase.movieDetailResult = Just(makeDetail(posterPath: "/poster.jpg"))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertEqual(sut.posterImage, "/poster.jpg")
    }

    func test_title_withReleaseDateAndTitle_includesYear() throws {
        let releaseDate = DateFormatter.yyyyMMdd.date(from: "2010-07-16")!
        mockUseCase.movieDetailResult = Just(makeDetail(title: "Inception", releaseDate: releaseDate))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertEqual(sut.title, "Inception (2010)")
    }

    func test_title_withNilReleaseDate_returnsJustTitle() throws {
        mockUseCase.movieDetailResult = Just(makeDetail(title: "Inception", releaseDate: nil))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertEqual(sut.title, "Inception")
    }

    func test_genres_joinsGenreNamesWithComma() throws {
        let genres = [Genre(id: 28, name: "Action"), Genre(id: 12, name: "Adventure")]
        mockUseCase.movieDetailResult = Just(makeDetail(genres: genres))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertEqual(sut.genres, "Action, Adventure")
    }

    func test_supportedLanguage_joinsLanguageNamesWithComma() throws {
        let languages = [
            SpokenLanguage(iso6391: "en", name: "English"),
            SpokenLanguage(iso6391: "fr", name: "French"),
        ]
        mockUseCase.movieDetailResult = Just(makeDetail(spokenLanguages: languages))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertEqual(sut.supportedLanguage, "English, French")
    }

    func test_status_returnsStatusString() throws {
        mockUseCase.movieDetailResult = Just(makeDetail(status: "Released"))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertEqual(sut.status, "Released")
    }

    func test_duration_withRuntime_returnsFormattedString() throws {
        mockUseCase.movieDetailResult = Just(makeDetail(runtime: 90))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertFalse(sut.duration.isEmpty)
        XCTAssertTrue(sut.duration.lowercased().contains("hour") || sut.duration.lowercased().contains("minute"))
    }

    func test_budget_formatsWithCurrencySymbol() throws {
        mockUseCase.movieDetailResult = Just(makeDetail(budget: 160_000_000))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertFalse(sut.budget.isEmpty)
        XCTAssertTrue(sut.budget.contains("$"))
    }

    func test_revenue_formatsWithCurrencySymbol() throws {
        mockUseCase.movieDetailResult = Just(makeDetail(revenue: 825_000_000))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertFalse(sut.revenue.isEmpty)
        XCTAssertTrue(sut.revenue.contains("$"))
    }

    func test_homePage_returnsHomepageString() throws {
        mockUseCase.movieDetailResult = Just(makeDetail(homepage: "https://example.com"))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertEqual(sut.homePage, "https://example.com")
    }

    func test_overview_returnsOverviewString() throws {
        mockUseCase.movieDetailResult = Just(makeDetail(overview: "A mind-bending thriller."))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
        let sut = makeSUT()
        try waitForNextValue(in: sut.$movieDetails)
        XCTAssertEqual(sut.overView, "A mind-bending thriller.")
    }
}
