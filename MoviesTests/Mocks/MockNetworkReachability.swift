import Combine
import Foundation
@testable import MoviesAppTask

final class MockNetworkReachability: NetworkReachabilityProtocol {
    var isConnected: Bool = true

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        Just(isConnected).eraseToAnyPublisher()
    }

    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0

    func start() { startCallCount += 1 }
    func stop() { stopCallCount += 1 }
}
