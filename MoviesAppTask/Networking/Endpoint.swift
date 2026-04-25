import Foundation

// MARK: - Endpoint

/// Defines the essential requirements for any API endpoint.
/// Conforming to this protocol ensures that a request can be properly constructed.
protocol Endpoint {
    /// The base URL for the API endpoint.
    var baseURL: URL { get }
    /// The specific path component for the API endpoint (e.g., "movie/popular").
    var path: String { get }
    /// The HTTP method for the request (e.g., GET, POST).
    var method: HTTPMethod { get }
    /// Optional HTTP headers for the request.
    var headers: [String: String]? { get }
    /// Optional parameters for the request, to be encoded based on `parameterEncoding`.
    var parameters: [String: Any]? { get }
    /// The strategy for encoding request parameters (e.g., URL query, JSON body).
    var parameterEncoding: ParameterEncoding { get }
}

extension Endpoint {
    /// Default implementation for `baseURL`, retrieving it from `NetworkConfiguration`.
    var baseURL: URL {
        guard let url = URL(string: NetworkConfiguration.shared.baseURL) else {
            preconditionFailure("Invalid base URL string configured in NetworkConfiguration.")
        }
        return url
    }

    /// Default empty headers if not specified by the conforming type.
    var headers: [String: String]? {
        return nil
    }

    /// Default parameter encoding for GET requests is URL encoding.
    var parameterEncoding: ParameterEncoding {
        return .urlEncoding
    }
}
