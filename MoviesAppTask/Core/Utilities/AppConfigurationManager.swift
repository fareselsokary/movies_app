import Foundation

// MARK: - AppConfigurationManagerProtocol

/// Protocol defining access to the app's build environment.
///
/// Allows checking whether the app is running in debug or release mode.
protocol AppConfigurationManagerProtocol: AnyObject {
    /// The current build environment.
    var currentEnvironment: AppConfigurationManager.BuildEnvironment { get }

    /// True if the app is running in the debug environment.
    var isDebugEnvironment: Bool { get }

    /// True if the app is running in the release environment.
    var isReleaseEnvironment: Bool { get }
}

// MARK: - AppConfigurationManager

/// Manages application configuration based on build environment.
///
/// Uses the app's Info.plist to determine the current build environment and exposes
/// helper properties for environment checks. Designed as a singleton for global access.
class AppConfigurationManager: AppConfigurationManagerProtocol {
    // MARK: - BuildEnvironment

    /// Enum representing possible build environments.
    enum BuildEnvironment: String {
        /// Debug environment
        case debug = "Debug"
        /// Release environment
        case release = "Release"
    }

    // MARK: - Properties

    /// The current build environment.
    private(set) var currentEnvironment: BuildEnvironment

    /// Returns true if the current environment is debug.
    var isDebugEnvironment: Bool { currentEnvironment == .debug }

    /// Returns true if the current environment is release.
    var isReleaseEnvironment: Bool { currentEnvironment == .release }

    // MARK: - Singleton

    /// Shared singleton instance of the configuration manager.
    static let shared = AppConfigurationManager()

    // MARK: - Initializer

    /// Initializes the configuration manager.
    ///
    /// - Parameter bundle: Bundle to read Info.plist values from. Defaults to `Bundle.main`.
    init(bundle: Bundle = Bundle.main) {
        let configValue = bundle.object(forInfoDictionaryKey: .configuration)
        currentEnvironment = BuildEnvironment(rawValue: configValue) ?? .debug
    }
}

// MARK: - BundleConfigurationKey

/// Keys used to read configuration values from the app's Info.plist.
enum BundleConfigurationKey: String {
    /// Key for build configuration (Debug/Release)
    case configuration = "Configuration"
    /// Base URL for API requests
    case baseURL = "BASE_URL"
    /// API key for network requests
    case apiKey = "API_KEY"
    /// Base URL for image resources
    case imageBaseUrl = "IMAGE_BASE_URL"
}
