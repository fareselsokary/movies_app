import SwiftUI

@main
struct MoviesApp: App {
    @StateObject private var appCoordinator: AppCoordinator

    init() {
        AppConfigurator.configure()
        _appCoordinator = StateObject(wrappedValue: AppCoordinator())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(coordinator: appCoordinator)
        }
    }
}
