import Foundation

/// Defines strategies for encoding parameters into a `URLRequest`.
enum ParameterEncoding {
    /// Encode parameters as query string items appended to the URL.
    case urlEncoding
    /// Encode parameters as a JSON payload in the HTTP body.
    case jsonEncoding

    /// Encodes the provided parameters into the specified `URLRequest`.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` to encode the parameters into.
    ///   - parameters: A dictionary of `[String: Any]` representing the parameters to encode.
    /// - Throws:
    ///   - `NetworkError.invalidURL` if the request's URL is `nil` or cannot be processed.
    ///   - `Error` if JSON encoding fails.
    func encode(_ urlRequest: inout URLRequest, with parameters: [String: Any]?) throws {
        // Exit early if there's nothing to encode.
        guard let parameters = parameters, !parameters.isEmpty else { return }

        switch self {
        case .urlEncoding:
            // Ensure there's a valid base URL.
            guard let url = urlRequest.url else {
                throw NetworkError.invalidURL
            }

            // Decompose the URL into components so we can add new query items.
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                components.queryItems = parameters.map { key, value in
                    URLQueryItem(name: key, value: "\(value)")
                }
                urlRequest.url = components.url
            }

        case .jsonEncoding:
            // Serialize the parameters into JSON data and set appropriate content type.
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            urlRequest.httpBody = jsonData
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
