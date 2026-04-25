import Foundation

// MARK: - NetworkError

/// Defines specific error types that can occur during network operations.
enum NetworkError: Error, Equatable {
    case invalidURL /// The constructed URL was invalid.
    case noData /// No data was returned from the server.
    case decodingError(Error) /// Failed to decode the server response into a Decodable type.
    case serverError(statusCode: Int, message: String?) /// An HTTP server error occurred.
    case badRequest /// The request itself was malformed or invalid.
    case unknown(Error?) /// An unhandled or unknown error occurred.

    /// Conformance to `Equatable` for easier testing and comparison of errors.
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.badRequest, .badRequest):
            return true
        case let (.decodingError(lhsErr), .decodingError(rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription // Compare descriptions for associated values
        case let (.serverError(s1, m1), .serverError(s2, m2)):
            return s1 == s2 && m1 == m2
        case let (.unknown(lhsErr), .unknown(rhsErr)):
            return lhsErr?.localizedDescription == rhsErr?.localizedDescription
        default:
            return false
        }
    }
}

// MARK: LocalizedError

/// Provides localized descriptions for `NetworkError` types, conforming to `LocalizedError`.
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid. Please try again."
        case .noData:
            return "No data was received from the server."
        case let .decodingError(error):
            return "Failed to process data: \(error.localizedDescription)"
        case let .serverError(statusCode, message):
            return "Server error \(statusCode): \(message ?? "An unexpected server error occurred.")"
        case .badRequest:
            return "The request was malformed. Please check inputs."
        case let .unknown(error):
            return "An unknown error occurred: \(error?.localizedDescription ?? "No additional information.")"
        }
    }
}
