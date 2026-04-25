import Foundation

/// Manages global networking parameters such as base URLs and API keys.
final class NetworkConfiguration {
    /// Shared singleton instance, thread-safe and lazily initialized.
    static let shared = NetworkConfiguration()

    /// The base URL for API requests.
    var baseURL: String

    /// Default headers for all network requests.
    var defaultHeaders: [String: String]?

    /// Private initializer ensures only one instance.
    private init() {
        baseURL = ""
        defaultHeaders = nil
    }
}
