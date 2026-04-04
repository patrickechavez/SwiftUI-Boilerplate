import SwiftUI

struct RouterNavigationModifier<R: RouterProtocol>: ViewModifier {
    @EnvironmentObject private var router: R
    @Environment(\.viewFactory) private var viewFactory

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Route.self) { route in
                if let factory = viewFactory {
                    factory.makeRouteDestination(route, router: router)
                } else {
                    EmptyView()
                        .onAppear {
                            assertionFailure("ViewFactory not set in environment — navigation destinations will not render")
                        }
                }
            }
    }
}

extension View {
    func withRouter<R: RouterProtocol>(_: R.Type) -> some View {
        modifier(RouterNavigationModifier<R>())
    }
}
