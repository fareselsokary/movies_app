import Combine
import SwiftUI

// MARK: - AppCoordinator

final class AppCoordinator: ObservableObject {
    let router = Router<AppRoute>()
}

// MARK: Coordinator

extension AppCoordinator: Coordinator {
    @ViewBuilder
    func start() -> some View {
        makeDestination(for: .home)
    }

    @ViewBuilder
    func makeDestination(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView(
                viewModel: HomeViewModel(
                    homeUseCase: HomeUseCase(),
                    navigator: self
                )
            )

        case let .movieDetail(id):
            MovieDetailView(
                viewModel: MovieDetailViewModel(
                    movieId: id,
                    movieDetailUseCase: MovieDetailUseCase()
                )
            )
        }
    }
}

// MARK: HomeNavigator

extension AppCoordinator: HomeNavigator {
    func showMovieDetail(id: Int) {
        router.push(.movieDetail(id: id))
    }
}
