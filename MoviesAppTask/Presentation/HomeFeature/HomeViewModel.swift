import Combine
import Foundation

// MARK: - HomeNavigator

protocol HomeNavigator: AnyObject {
    func showMovieDetail(id: Int)
}

// MARK: - HomeViewModel

/// The ViewModel for the Home screen, managing trending movies, genre filtering, and navigation logic.
/// It coordinates through `HomeUseCaseProtocol` and handles UI-binding states.
final class HomeViewModel: ObservableObject {
    // MARK: - Published UI Bindings

    /// The list of movies filtered based on genre and search text.
    @Published private(set) var filteredMovies: [Movie] = []

    /// The list of available movie genres.
    @Published private(set) var genres: [Genre] = []

    /// The ID of the currently selected genre, if any.
    @Published var selectedGenreId: Int?

    /// The search text entered by the user.
    @Published var searchText: String = ""

    /// All movies fetched from the backend (used before filtering).
    @Published private var movies: [Movie] = []

    // MARK: - Pagination and State

    /// The current page of trending movies being fetched.
    private var currentPage = 1

    /// The total number of available pages from the backend.
    private var totalPages = 1

    /// Number of items per page.
    private var pageSize = Constants.pageSize

    /// Indicates whether more movies are currently being loaded.
    private var isLoadingMore: Bool = false

    /// Indicates whether a refresh action is being performed.
    private var isRefreshing: Bool = false

    // MARK: - Dependencies

    private let homeUseCase: HomeUseCaseProtocol
    private weak var navigator: HomeNavigator?

    // MARK: - Combine Cancellables

    private var cancellables = Set<AnyCancellable>()
    private var genreFetchCancellable: AnyCancellable?
    private var moviesFetchCancellable: AnyCancellable?

    // MARK: - Initialization

    /// Initializes the view model with a use case.
    /// - Parameter homeUseCase: The use case handling movie and genre operations.
    init(
        homeUseCase: HomeUseCaseProtocol,
        navigator: HomeNavigator
    ) {
        self.homeUseCase = homeUseCase
        self.navigator = navigator
        bindFilters()
        loadGenres()
        loadMoreMovies()
    }
}

extension HomeViewModel {
    func didSelectMovie(_ id: Int) {
        navigator?.showMovieDetail(id: id)
    }
}

extension HomeViewModel {
    // MARK: - Public Actions

    /// Refreshes the movie list and resets pagination and filters.
    func refresh() {
        currentPage = 1
        totalPages = 1
        isLoadingMore = false
        isRefreshing = true
        selectedGenreId = nil
        loadMoreMovies(shouldResetCache: true)
    }

    func fetchNextPage(current movie: Movie) {
        if filteredMovies.last?.id == movie.id {
            loadMoreMovies(shouldResetCache: false)
        }
    }

    /// Loads more trending movies for the current page and appends them to the list.
    private func loadMoreMovies(shouldResetCache: Bool = false) {
        guard !isLoadingMore else { return }
        guard currentPage <= totalPages || currentPage == 1 else { return }

        isLoadingMore = true

        moviesFetchCancellable?.cancel()
        moviesFetchCancellable = homeUseCase
            .fetchTrendingMovies(
                pageSize: pageSize,
                page: currentPage,
                shouldResetCache: shouldResetCache
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }

                if case let .failure(error) = completion {
                    Logger.error(error.localizedDescription)
                }

                self.isLoadingMore = false
                self.isRefreshing = false
            } receiveValue: { [weak self] response in
                guard let self else { return }

                if self.isRefreshing {
                    self.movies = response.results
                } else {
                    self.movies += response.results
                }

                self.currentPage += 1
                self.totalPages = response.totalPages
                self.isLoadingMore = false
                self.isRefreshing = false
            }
    }

    /// Loads the list of genres used for filtering.
    func loadGenres() {
        genreFetchCancellable?.cancel()
        genreFetchCancellable = homeUseCase
            .fetchMovieGenres()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    Logger.error(error.localizedDescription)
                }
            } receiveValue: { [weak self] response in
                self?.genres = response
            }
    }

    /// Applies a search filter to the movie list.
    /// - Parameter query: The search query string entered by the user.
    func applySearchFilter(query: String) {
        searchText = query
    }
}

// MARK: - Private Helpers

private extension HomeViewModel {
    /// Binds the movie list to filters for genre and search text.
    func bindFilters() {
        Publishers.CombineLatest3(
            $movies,
            $searchText.removeDuplicates(),
            $selectedGenreId.removeDuplicates()
        )
        .map { movies, searchText, genreID in
            var filtered = movies

            if !searchText.isBlankString {
                filtered = filtered.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                }
            }

            if let genreID {
                filtered = filtered.filter {
                    $0.genreIds.contains(genreID)
                }
            }

            return filtered.unique(by: { $0.id }) // API sometimes returns duplicate movies
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$filteredMovies)
    }
}

// MARK: - Computed UI State

extension HomeViewModel {
    /// The appropriate empty state message to show based on user input and loading status.
    var message: String {
        if !searchText.isBlankString {
            return "No movies found matching \"\(searchText)\""
        } else if isLoadingMore || isRefreshing {
            return ""
        } else {
            return "No movies found"
        }
    }

    /// Whether the initial loading spinner should be shown.
    var isLoading: Bool {
        guard currentPage == 1 else { return false }
        return isLoadingMore || isRefreshing
    }
}
