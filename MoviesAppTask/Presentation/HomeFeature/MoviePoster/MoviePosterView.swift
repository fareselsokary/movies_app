import SwiftUI

// MARK: - MoviePosterView

struct MoviePosterView: View {
    let viewModel: MoviePosterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Style.outerSpacing) {
            AsyncImageView(path: viewModel.imageURL)
                .aspectRatio(Style.aspectRatio, contentMode: .fill)
                .clipped()

            VStack(alignment: .leading, spacing: Style.innerSpacing) {
                Text(viewModel.title)
                    .font(.footnote.bold())
                    .lineLimit(Style.titleLineLimit, reservesSpace: true)

                if let releaseData = viewModel.releaseData {
                    Text(releaseData)
                        .font(.caption)
                }
            }
            .padding([.horizontal, .bottom], Style.contentPadding)
        }
        .background(Color.gray.opacity(Style.backgroundOpacity))
        .cornerRadius(Style.cornerRadius)
        .clipped()
    }
}

// MARK: MoviePosterView.Style

private extension MoviePosterView {
    enum Style {
        static let outerSpacing: CGFloat = 8
        static let innerSpacing: CGFloat = 8
        static let contentPadding: CGFloat = 8
        static let aspectRatio: CGFloat = 0.95
        static let backgroundOpacity: CGFloat = 0.1
        static let cornerRadius: CGFloat = 8
        static let titleLineLimit: Int = 2
    }
}

#Preview {
    MoviePosterView(viewModel: MoviePosterViewModel(
        id: 1,
        imageURL: "/6WxhEvFsauuACfv8HyoVX6mZKFj.jpg",
        title: "Final Destination Bloodlines",
        releaseData: Date()
    ))
}
