import Foundation

// MARK: - Shared API Models

/// Represents a paginated response structure from the API.
/// - T: The `Decodable` type of the results within the page.
struct APIPaginatedResponse<T: Decodable>: Decodable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    /// Coding keys to map snake_case API response fields to camelCase Swift properties.
    private enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
