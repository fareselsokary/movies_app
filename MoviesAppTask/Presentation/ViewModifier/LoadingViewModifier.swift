import SwiftUI

extension View {
    /// A custom view modifier that displays a `ProgressView` overlay when `isLoading` is true.
    /// - Parameter isLoading: A boolean binding that controls the visibility of the loading indicator.
    /// - Returns: A new view with the loading overlay applied.
    func loading(isLoading: Bool, message: String? = nil) -> some View {
        modifier(LoadingViewModifier(isLoading: isLoading, message: message))
    }
}

// MARK: - LoadingViewModifier

/// A `ViewModifier` to present a circular progress view as an overlay.
private struct LoadingViewModifier: ViewModifier {
    let isLoading: Bool
    let message: String?

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)

                    if let message = message,
                       !message.isEmpty {
                        Text(message)
                            .foregroundColor(.white)
                            .font(.body)
                    }
                }
                .padding(24)
                .background(.thinMaterial)
                .cornerRadius(12)
            }
        }
    }
}
