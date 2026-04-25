import Foundation

// MARK: - Bundle + Configuration

/// An extension on `Bundle` that simplifies retrieving configuration values
/// (such as API keys or base URLs) from the app’s `Info.plist` using a type-safe key.
///
/// This approach uses a custom `BundleConfigurationKey` enum (defined elsewhere)
/// to avoid hardcoded string literals and improve maintainability.
extension Bundle {
    /// Retrieves an object from the app’s `Info.plist` using a strongly typed key.
    ///
    /// - Parameter key: A `BundleConfigurationKey` representing a predefined key in the app’s configuration.
    /// - Returns: The value associated with the given key, as a `String`.
    ///
    /// ### Example
    /// ```swift
    /// let apiKey = Bundle.main.object(forInfoDictionaryKey: .apiKey)
    /// print(apiKey) // "12345-ABCDE"
    /// ```
    ///
    /// ### Notes
    /// - This method **force unwraps** the result (`as! String`), so it will **crash** at runtime
    ///   if the key is missing or not a `String`.
    /// - Use only for keys guaranteed to exist in `Info.plist`.
    /// - Consider adding a safe version that returns an optional if you need more resilience.
    func object(forInfoDictionaryKey key: BundleConfigurationKey) -> String {
        guard let value = object(forInfoDictionaryKey: key.rawValue) as? String else {
            fatalError("Missing or invalid Info.plist value for key: \(key.rawValue)")
        }
        return value
    }
}
