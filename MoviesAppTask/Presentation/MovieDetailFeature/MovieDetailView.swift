import SwiftUI

// MARK: - MovieDetailView

struct MovieDetailView: View {
    // MARK: - Properties

    /// View model containing movie data and business logic
    @StateObject var viewModel: MovieDetailViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization

    /// Initializes the MovieDetailView with a view model
    /// - Parameter viewModel: The view model containing movie data
    init(viewModel: MovieDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Style.outerSpacing) {
                // Header image with parallax effects
                headerImage()

                // Main content section with movie information
                VStack(alignment: .leading, spacing: Style.innerSpacing) {
                    // Movie poster and basic info section
                    HStack(alignment: .top, spacing: Style.innerSpacing) {
                        AsyncImageView(path: viewModel.posterImage)
                            .scaledToFill()
                            .frame(
                                width: Style.posterWidth,
                                height: Style.posterHeight
                            )
                            .clipped()

                        // Title and genres section
                        VStack(alignment: .leading, spacing: Style.titleGenreSpacing) {
                            // Movie title
                            Text(viewModel.title)
                                .foregroundStyle(Color.white)
                                .font(.headline.bold())
                                .multilineTextAlignment(.leading)

                            // Movie genres
                            Text(viewModel.genres)
                                .foregroundStyle(Color.white)
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer()
                    }

                    // Movie description
                    Text(viewModel.overView)
                        .foregroundStyle(Color.white)
                        .font(.body.weight(.medium))
                        .multilineTextAlignment(.leading)

                    // Detailed movie information section
                    movieDetailsSection()
                        .padding(.top, Style.detailsTopPadding)
                }
                .padding(.horizontal, Style.horizontalPadding)
            }
        }
        .loading(isLoading: viewModel.isLoading, message: "Loading...")
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Custom back button
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                }
            }

            // Share button
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    // TODO: Implement share functionality
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Private Extensions

private extension MovieDetailView {
    /// Creates the header image with parallax scrolling and blur effects
    func headerImage() -> some View {
        let blurDivisor = Style.blurDivisor
        let blurMax = Style.blurMax

        return AsyncImageView(
            path: viewModel.headerImage,
            size: Constants.backdropImageSize
        )
        .containerRelativeFrame(.vertical) { length, _ in
            length / Style.backdropHeightDivisor
        }
        .scaledToFill()
        .clipped()
        .visualEffect { effect, geometry in
            // Get current dimensions and scroll position
            let currentHeight = geometry.size.height
            let scrollOffset = geometry.frame(in: .scrollView).minY
            let positiveOffset = max(0, scrollOffset) // Only consider positive scroll offsets

            // Calculate new height and scale factor for parallax effect
            let newHeight = currentHeight + positiveOffset
            let scaleFactor = newHeight / currentHeight

            // Calculate blur amount based on scroll position (max 20 points)
            let blurAmount = min(positiveOffset / blurDivisor, blurMax)

            // Apply visual effects
            return effect
                .scaleEffect(x: scaleFactor, y: scaleFactor, anchor: .bottom) // Scale from bottom
                .blur(radius: blurAmount) // Progressive blur on scroll
        }
    }

    /// Creates the detailed movie information section
    func movieDetailsSection() -> some View {
        VStack(alignment: .leading, spacing: Style.titleGenreSpacing) {
            MovieDetailRowView(label: "HomePage", value: viewModel.homePage, redirect: true)

            MovieDetailRowView(label: "Language", value: viewModel.supportedLanguage)

            HStack(alignment: .center, spacing: Style.innerSpacing) {
                VStack(alignment: .leading, spacing: Style.titleGenreSpacing) {
                    MovieDetailRowView(label: "Status", value: viewModel.status)
                    MovieDetailRowView(label: "Budget", value: viewModel.budget)
                }

                Spacer()

                VStack(alignment: .leading, spacing: Style.titleGenreSpacing) {
                    MovieDetailRowView(label: "Runtime", value: viewModel.duration)
                    MovieDetailRowView(label: "Revenue", value: viewModel.revenue)
                }
            }
        }
    }
}

// MARK: MovieDetailView.Style

private extension MovieDetailView {
    enum Style {
        static let outerSpacing: CGFloat = 16
        static let innerSpacing: CGFloat = 16
        static let titleGenreSpacing: CGFloat = 4
        static let posterWidth: CGFloat = 90
        static let posterHeight: CGFloat = 140
        static let detailsTopPadding: CGFloat = 24
        static let horizontalPadding: CGFloat = 8
        static let backdropHeightDivisor: CGFloat = 2.5
        static let blurDivisor: CGFloat = 12.5
        static let blurMax: CGFloat = 20
    }
}

// MARK: - Preview

#Preview {
    MovieDetailView(viewModel: MovieDetailViewModel(
        movieId: 574_475,
        movieDetailUseCase: MovieDetailUseCase()
    ))
    .preferredColorScheme(.dark)
}
