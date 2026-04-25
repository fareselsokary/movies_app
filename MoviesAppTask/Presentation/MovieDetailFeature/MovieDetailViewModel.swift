import Combine
import Foundation

// MARK: - MovieDetailViewModel

final class MovieDetailViewModel: ObservableObject {
    // MARK: - Published UI Bindings

    @Published private(set) var movieDetails: MovieDetail?
    @Published private(set) var isLoading: Bool = false

    // MARK: - Dependencies

    private let movieId: Int
    private let movieDetailUseCase: MovieDetailUseCaseProtocol

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        movieId: Int,
        movieDetailUseCase: MovieDetailUseCaseProtocol
    ) {
        self.movieId = movieId
        self.movieDetailUseCase = movieDetailUseCase
        loadMovieDetails()
    }

    // MARK: - Public Actions

    func loadMovieDetails() {
        guard !isLoading else { return }
        isLoading = true

        movieDetailUseCase
            .fetchMovieDetails(movieId: movieId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false

                if case let .failure(error) = completion {
                    Logger.error("Failed to load movie details for ID \(self.movieId): \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] movieDetail in
                guard let self else { return }
                self.movieDetails = movieDetail
                self.isLoading = false
                Logger.verbose("Successfully loaded movie details for ID \(movieDetail.id).")
            }
            .store(in: &cancellables)
    }
}

// MARK: - Computed Properties

extension MovieDetailViewModel {
    var headerImage: String {
        movieDetails?.backdropPath ?? ""
    }

    var posterImage: String {
        movieDetails?.posterPath ?? ""
    }

    var title: String {
        let releaseDate = movieDetails?.releaseDate?.formattedYear() ?? ""
        let title = movieDetails?.title ?? ""
        return releaseDate.isEmpty ? title : "\(title) (\(releaseDate))"
    }

    var genres: String {
        movieDetails?.genres.compactMap { $0.name }.joined(separator: ", ") ?? ""
    }

    var overView: String {
        movieDetails?.overview ?? ""
    }

    var homePage: String {
        movieDetails?.homepage ?? ""
    }

    var supportedLanguage: String {
        movieDetails?.spokenLanguages.compactMap { $0.name }.joined(separator: ", ") ?? ""
    }

    var status: String {
        movieDetails?.status ?? ""
    }

    var duration: String {
        movieDetails?.runtime?.formattedHoursAndMinutes ?? ""
    }

    var budget: String {
        movieDetails?.budget?.formattedPrice() ?? ""
    }

    var revenue: String {
        movieDetails?.revenue?.formattedPrice() ?? ""
    }
}
