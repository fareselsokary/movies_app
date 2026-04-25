import SwiftData

/// A singleton that holds the app's SwiftData `ModelContainer`.
///
/// Provides a single, shared container for all persistent models used in the app.
final class AppModelContainer {
    // MARK: - Singleton

    /// The shared instance of `AppModelContainer`.
    static let shared = AppModelContainer()

    // MARK: - Properties

    /// The SwiftData container configured with all cached entity models.
    let container: ModelContainer

    // MARK: - Init

    /// Initializes the container with the app's persistent models.
    ///
    /// Crashes the app if the container fails to initialize, since persistence
    /// is required for the app to function.
    private init() {
        do {
            container = try ModelContainer(
                for: CachedGenreEntity.self,
                CachedMovieEntity.self,
                CachedSpokenLanguageEntity.self
            )
        } catch {
            fatalError("ModelContainer init error: \(error)")
        }
    }
}
