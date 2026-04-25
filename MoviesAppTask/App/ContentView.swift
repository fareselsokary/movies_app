import SwiftUI

struct ContentView<C: Coordinator>: View {
    let coordinator: C
    @ObservedObject private var router: Router<C.Route>

    init(coordinator: C) {
        self.coordinator = coordinator
        _router = ObservedObject(wrappedValue: coordinator.router)
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            coordinator.start()
                .navigationDestination(for: C.Route.self) { route in
                    coordinator.makeDestination(for: route)
                }
        }
    }
}
