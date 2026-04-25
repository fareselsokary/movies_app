import Kingfisher
import SwiftUI

// MARK: - AsyncImageView

/// A view that asynchronously loads and displays an image with an optional placeholder.
/// Uses `Kingfisher` under the hood for fetching and caching images.
struct AsyncImageView<Placeholder: View>: View {
    private let imageURL: URL?
    private let placeholder: () -> Placeholder

    // MARK: - Main Initializer

    /// Creates an image view for a URL, with an optional placeholder.
    ///
    /// - Parameters:
    ///   - imageURL: The remote image URL.
    ///   - placeholder: A view builder for the placeholder displayed while loading. Defaults to a light gray rectangle.
    init(
        _ imageURL: URL?,
        @ViewBuilder placeholder: @escaping () -> Placeholder = { Color.gray.opacity(0.2) }
    ) {
        self.imageURL = imageURL
        self.placeholder = placeholder
    }

    /// Creates an image view for a string URL, with an optional placeholder.
    ///
    /// - Parameters:
    ///   - imageURL: The remote image URL string.
    ///   - placeholder: A view builder for the placeholder displayed while loading. Defaults to a light gray rectangle.
    init(
        _ imageURL: String?,
        @ViewBuilder placeholder: @escaping () -> Placeholder = { Color.gray.opacity(0.2) }
    ) {
        self.imageURL = URL(string: imageURL ?? "")
        self.placeholder = placeholder
    }

    // MARK: - Body

    var body: some View {
        KFImage(imageURL)
            .resizable()
            .placeholder { placeholder() }
            .fade(duration: 0.2)
            .cancelOnDisappear(true)
    }
}

// MARK: - TMDb Helper

extension AsyncImageView {
    /// Creates an `AsyncImageView` for an image from TMDb path.
    ///
    /// - Parameters:
    ///   - tmdbBaseUrl: Base image URL (`https://image.tmdb.org/t/p/`)
    ///   - path: TMDb image path (can be `nil`)
    ///   - size: Image size (`"w500"` etc.)
    ///   - placeholder: Optional placeholder view. Defaults to a light gray rectangle.
    init(
        tmdbBaseUrl: String = Bundle.main.object(forInfoDictionaryKey: .imageBaseUrl),
        path: String?,
        size: String = Constants.posterImageSize,
        @ViewBuilder placeholder: @escaping () -> Placeholder = { Color.gray.opacity(0.2) }
    ) {
        let fullURL: URL? = {
            guard let path, !path.isEmpty else { return nil }
            return URL(string: "\(tmdbBaseUrl)\(size)\(path)")
        }()
        self.init(fullURL, placeholder: placeholder)
    }
}
