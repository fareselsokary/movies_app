import Combine

// MARK: - NetworkReachabilityProtocol

/// Describes the interface for observing network connectivity changes.
/// Conform to this protocol to provide real or mock implementations for
/// production use and testing respectively.
protocol NetworkReachabilityProtocol: AnyObject {
    /// A publisher that emits the current connectivity state whenever it changes.
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }

    /// The current network connectivity state.
    var isConnected: Bool { get }

    /// Begins monitoring network reachability.
    func start()

    /// Stops monitoring network reachability.
    func stop()
}
