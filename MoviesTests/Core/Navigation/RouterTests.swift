import XCTest
import Combine
@testable import MoviesAppTask

final class RouterTests: XCTestCase {

    private var router: Router<AppRoute>!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        router = Router<AppRoute>()
    }

    override func tearDown() {
        super.tearDown()
        router = nil
        cancellables.removeAll()
    }

    func test_initialPath_isEmpty() {
        XCTAssertTrue(router.path.isEmpty)
    }

    func test_push_addsRouteToPath() {
        router.push(.home)
        XCTAssertEqual(router.path, [.home])
    }

    func test_push_multipleRoutes_appendsInOrder() {
        router.push(.home)
        router.push(.movieDetail(id: 1))
        XCTAssertEqual(router.path, [.home, .movieDetail(id: 1)])
    }

    func test_pop_removesLastRoute() {
        router.push(.home)
        router.push(.movieDetail(id: 1))
        router.pop()
        XCTAssertEqual(router.path, [.home])
    }

    func test_pop_onEmptyPath_doesNotCrash() {
        router.pop()
        XCTAssertTrue(router.path.isEmpty)
    }

    func test_popToRoot_clearsAllRoutes() {
        router.push(.home)
        router.push(.movieDetail(id: 1))
        router.push(.movieDetail(id: 2))
        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
    }

    func test_popToRoot_onEmptyPath_doesNotCrash() {
        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
    }

    func test_replace_setsNewPath() {
        router.push(.home)
        router.replace(with: [.movieDetail(id: 5)])
        XCTAssertEqual(router.path, [.movieDetail(id: 5)])
    }

    func test_replace_withEmptyArray_clearsPath() {
        router.push(.home)
        router.replace(with: [])
        XCTAssertTrue(router.path.isEmpty)
    }

    func test_push_publishesPathChange() {
        let expectation = expectation(description: "path published")
        router.$path
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        router.push(.home)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_pop_publishesPathChange() {
        router.push(.home)
        let expectation = expectation(description: "path published after pop")
        router.$path
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        router.pop()
        wait(for: [expectation], timeout: 1.0)
    }
}
