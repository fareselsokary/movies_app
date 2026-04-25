import Combine
import Foundation
@testable import MoviesAppTask

final class MockNetworkService: NetworkServiceProtocol {
    var result: Any?
    var error: NetworkError?

    private(set) var requestCallCount = 0
    private(set) var lastEndpointPath: String?

    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        requestCallCount += 1
        lastEndpointPath = endpoint.path

        if let error = error {
            return Fail(error: error).eraseToAnyPublisher()
        }
        if let result = result as? T {
            return Just(result)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: .unknown(nil)).eraseToAnyPublisher()
    }
}
