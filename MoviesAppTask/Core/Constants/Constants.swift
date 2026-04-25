//
//  Constants.swift
//  Core
//

import Foundation

/// A struct to hold global constants for the application, such as API keys and base URLs.
enum Constants {
    // MARK: - Image Sizes

    /// Recommended image size for movie posters.
    static let posterImageSize = "w500" // Example: "w500", "original"
    /// Recommended image size for movie backdrops.
    static let backdropImageSize = "w1280" // Example: "w1280", "original"

    /// API request page size
    static let pageSize = 20
}
