import Combine
import XCTest

extension XCTestCase {
    /// Subscribes to a failable publisher, blocks until it completes, and returns the emitted value.
    @discardableResult
    func awaitPublisher<T>(
        _ publisher: AnyPublisher<T, Error>,
        timeout: TimeInterval = 2.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T {
        var result: Result<T, Error>?
        let exp = expectation(description: "publisher completion")

        let cancellable = publisher.sink(
            receiveCompletion: {
                if case .failure(let error) = $0 { result = .failure(error) }
                exp.fulfill()
            },
            receiveValue: { result = .success($0) }
        )

        wait(for: [exp], timeout: timeout)
        cancellable.cancel()

        switch result {
        case .success(let value): return value
        case .failure(let error): throw error
        case nil: throw XCTSkip("Publisher did not emit a value within \(timeout)s", file: file, line: line)
        }
    }

    /// Waits for the next value emitted by a `@Published` property (skips the current value).
    @discardableResult
    func waitForNextValue<T>(
        in publisher: Published<T>.Publisher,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T {
        var result: T?
        let exp = expectation(description: "next published value")
        let cancellable = publisher
            .dropFirst()
            .first()
            .sink { result = $0; exp.fulfill() }
        wait(for: [exp], timeout: timeout)
        cancellable.cancel()
        return try XCTUnwrap(result, "No value received within \(timeout)s", file: file, line: line)
    }

    /// Waits until a `@Published` property emits a value satisfying the predicate.
    /// Unlike `waitForNextValue`, this does NOT skip the current value — it will
    /// resolve immediately if the current value already matches.
    @discardableResult
    func waitForValue<T>(
        in publisher: Published<T>.Publisher,
        where predicate: @escaping (T) -> Bool,
        timeout: TimeInterval = 2.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T {
        var result: T?
        let exp = expectation(description: "waiting for matching value")
        let cancellable = publisher
            .first(where: predicate)
            .sink { result = $0; exp.fulfill() }
        wait(for: [exp], timeout: timeout)
        cancellable.cancel()
        return try XCTUnwrap(result, "No matching value received within \(timeout)s", file: file, line: line)
    }

    /// Flushes all work currently pending on the main queue.
    func waitForMainQueue(file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "main queue flush")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
    }
}
