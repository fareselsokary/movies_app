import SwiftUI

// MARK: - HomeView

/// The main view for the Home feature, displaying trending movies and genre filters.
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: Style.verticalSpacing) {
            Text("Watch New Movies")
                .font(.title.bold())
                .foregroundColor(.orange)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            SearchBar(text: $viewModel.searchText, placeholder: "Search TMDP")
                .padding(.horizontal, Style.horizontalPadding)

            GenreFilterBarView(
                viewModel: GenreFilterBarViewModel(genres: viewModel.genres),
                selectedGenreId: $viewModel.selectedGenreId
            )

            VGridView(
                columns: Style.gridColumns,
                columnsSpacing: Style.gridSpacing,
                rowSpacing: Style.gridSpacing,
                items: viewModel.filteredMovies
            ) { movie, index in
                MoviePosterView(
                    viewModel: MoviePosterViewModel(
                        id: movie.id,
                        imageURL: movie.posterPath,
                        title: movie.title,
                        releaseData: movie.releaseDate
                    )
                )
                .onTapGesture {
                    viewModel.didSelectMovie(movie.id)
                }
                .onAppear {
                    viewModel.fetchNextPage(current: movie)
                }
            } emptyView: {
                Text(viewModel.message)
                    .frame(height: Style.emptyHeight)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Style.horizontalPadding)
        }
        .loading(isLoading: viewModel.isLoading, message: "Loading Movies...")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Watch New Movies")
                    .font(.title.bold())
                    .foregroundColor(.orange)
            }
        }
        .setNavigationBarHidden(true)
        .refreshable {
            viewModel.refresh()
        }
    }
}

// MARK: HomeView.Style

private extension HomeView {
    enum Style {
        static let verticalSpacing: CGFloat = 16
        static let horizontalPadding: CGFloat = 8
        static let gridColumns: Int = 2
        static let gridSpacing: CGFloat = 8
        static let emptyHeight: CGFloat = 300
    }
}
