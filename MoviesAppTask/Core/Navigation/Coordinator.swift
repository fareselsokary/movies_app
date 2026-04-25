import SwiftUI

protocol Coordinator: AnyObject {
    associatedtype RootView: View
    associatedtype DestinationView: View
    associatedtype Route: Hashable

    var router: Router<Route> { get }

    @ViewBuilder
    func start() -> RootView

    @ViewBuilder
    func makeDestination(for route: Route) -> DestinationView
}
