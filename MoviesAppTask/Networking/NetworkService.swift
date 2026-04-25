import Foundation
import Combine

// MARK: - NetworkServiceProtocol

/// A protocol defining the contract for a generic network service.
protocol NetworkServiceProtocol {
    /// Performs a network request to the specified endpoint and decodes the response.
    /// - Parameter endpoint: The `Endpoint` defining the request details.
    /// - Returns: A `AnyPublisher` that emits the decoded `Decodable` type or a `NetworkError`.
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError>
}

// MARK: - NetworkService

/// A concrete implementation of `NetworkServiceProtocol` using `URLSession`.
class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    /// Initializes the `NetworkService` with an optional `URLSession`.
    /// - Parameter session: The `URLSession` to use for requests (defaults to `.shared`).
    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    /// Performs a network request and decodes the response.
    /// - Parameter endpoint: The `Endpoint` for the request.
    /// - Returns: A publisher for the decoded `Decodable` type or a `NetworkError`.
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        // Construct the full URL with base URL and path.
        guard var urlComponents = URLComponents(
            url: endpoint.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: true
        ) else {
            Logger.error("Invalid URL for endpoint: \(endpoint.path)")
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }

        // Add the API key as a query parameter for all requests.
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []

        // Add additional parameters for GET requests.
        if endpoint.method == .get, let params = endpoint.parameters {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: "\($0.value)") })
        }
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }

        // Finalize the URL after adding all parameters.
        guard let finalURL = urlComponents.url else {
            Logger.error("Final URL could not be constructed for endpoint: \(endpoint.path)")
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue

        // Add any custom headers defined in the endpoint.
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Encode parameters for non-GET requests (POST, PUT, DELETE).
        if endpoint.method != .get {
            do {
                try endpoint.parameterEncoding.encode(&request, with: endpoint.parameters)
            } catch let error as NetworkError {
                Logger.error("Parameter encoding failed for \(endpoint.path): \(error.localizedDescription)")
                return Fail(error: error).eraseToAnyPublisher()
            } catch {
                Logger.error("Unknown error during parameter encoding for \(endpoint.path): \(error.localizedDescription)")
                return Fail(error: .unknown(error)).eraseToAnyPublisher()
            }
        }

        Logger.verbose("Making request: \(request.url?.absoluteString ?? "N/A")")

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    Logger.error("Invalid HTTP response received.")
                    throw NetworkError.unknown(nil)
                }

                // Check for successful HTTP status codes (2xx).
                guard (200 ... 299).contains(httpResponse.statusCode) else {
                    let errorMessage = String(data: data, encoding: .utf8)
                    Logger.log("Server error \(httpResponse.statusCode) for \(endpoint.path): \(errorMessage ?? "No message")")
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
                }

                Logger.verbose("Received data (bytes): \(data.count)")
                return data
            }
            // Decode the data into the specified Decodable type.
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                Logger.error("Decoding or network error for \(endpoint.path): \(error.localizedDescription)")
                // Map various error types to `NetworkError`.
                if let decodingError = error as? DecodingError {
                    return NetworkError.decodingError(decodingError)
                } else if let networkError = error as? NetworkError {
                    return networkError
                } else if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                    return NetworkError.serverError(statusCode: -1009, message: "No internet connection")
                }
                return NetworkError.unknown(error)
            }
            .eraseToAnyPublisher()
    }
}

extension NetworkService {
    static let `default`: NetworkService = {
        // Configure the session as ephemeral
        let configuration = URLSessionConfiguration.ephemeral
        // You can also tweak other options
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        // Create the session
        let session = URLSession(configuration: configuration)
        return NetworkService(session: session, decoder: .init())
    }()
}
