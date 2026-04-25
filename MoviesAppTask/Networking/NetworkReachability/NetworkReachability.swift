import Combine
import Foundation
import Network

// MARK: - NetworkReachability

/// A concrete implementation of `NetworkReachabilityProtocol` backed by
/// `NWPathMonitor` from the Network framework.
///
/// Inject this via `NetworkReachabilityProtocol` at call sites so that
/// tests can swap in `MockNetworkReachability` without touching production code.
///
/// Usage:
/// ```swift
/// let reachability: NetworkReachabilityProtocol = NetworkReachability.shared
/// reachability.start()
/// reachability.isConnectedPublisher
///     .sink { isConnected in … }
///     .store(in: &cancellables)
/// ```
final class NetworkReachability: ObservableObject, NetworkReachabilityProtocol {
    // MARK: - Shared Instance

    /// Shared singleton instance. Prefer injecting `NetworkReachabilityProtocol`
    /// rather than referencing `.shared` directly in feature code.
    static let shared = NetworkReachability()

    // MARK: - Public Interface

    @Published private(set) var isConnected: Bool = true

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        $isConnected.eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "com.app.NetworkReachability", qos: .utility)

    // MARK: - Initialisation

    private init() {
        monitor = NWPathMonitor()
        configurePathUpdateHandler()
    }

    // MARK: - NetworkReachabilityProtocol

    func start() {
        monitor.start(queue: monitorQueue)
    }

    func stop() {
        monitor.cancel()
    }

    // MARK: - Deinit

    deinit {
        monitor.cancel()
    }

    // MARK: - Private Helpers

    private func configurePathUpdateHandler() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            DispatchQueue.main.async {
                self.isConnected = connected
                if connected {
                    Logger.verbose("Network status: Connected")
                } else {
                    Logger.error("Network status: Disconnected")
                }
            }
        }
    }
}
