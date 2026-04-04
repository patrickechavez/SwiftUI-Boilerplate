import SwiftUI

@MainActor
protocol ViewFactory {
    @ViewBuilder func makeRouteDestination(_ route: Route, router: any RouterProtocol) -> AnyView
    @ViewBuilder func makeAuthRouteDestination(_ route: AuthRoute, router: any RouterProtocol) -> AnyView
    @ViewBuilder func makeTabRootView(_ tab: AppTab, router: any RouterProtocol) -> AnyView
    @ViewBuilder func makeAuthRootView(router: any RouterProtocol) -> AnyView
}

private struct ViewFactoryKey: EnvironmentKey {
    static let defaultValue: (any ViewFactory)? = nil
}

extension EnvironmentValues {
    var viewFactory: (any ViewFactory)? {
        get { self[ViewFactoryKey.self] }
        set { self[ViewFactoryKey.self] = newValue }
    }
}
