import SwiftUI

@main
struct SwiftUI_BoilerplateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var coordinator: AppCoordinator

    private let container: DependencyContainer

    init() {
        let container = DependencyContainer()
        self.container = container
        _coordinator = StateObject(wrappedValue: container.makeAppCoordinator())
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if coordinator.isCheckingAuth {
                    ProgressView("Loading...")
                } else if coordinator.isAuthenticated {
                    MainTabView()
                } else {
                    AuthFlowView(authRouter: coordinator.authRouter)
                }
            }
            .environment(\.viewFactory, container)
            .environmentObject(coordinator)
            .onOpenURL { url in
                coordinator.handleDeepLink(url)
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveDeepLink)) { notification in
                if let url = notification.userInfo?["url"] as? URL {
                    coordinator.handleDeepLink(url)
                }
            }
            .task {
                await coordinator.checkAuthOnLaunch()
            }
        }
    }
}
