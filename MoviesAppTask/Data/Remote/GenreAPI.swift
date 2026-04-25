import Foundation

/// Defines specific API endpoints related to movie genres.
enum GenreAPI: Endpoint {
    case listGenres // Endpoint for fetching the list of movie genres.

    /// The path component for the genre API endpoint.
    var path: String {
        switch self {
        case .listGenres:
            return "genre/movie/list"
        }
    }

    /// The HTTP method for genre API requests (always GET for this endpoint).
    var method: HTTPMethod {
        return .get
    }

    /// Optional parameters for the genre API endpoint (none for this case).
    var parameters: [String: Any]? {
        return nil
    }

    var headers: [String: String]? {
        return NetworkConfiguration.shared.defaultHeaders
    }
}
