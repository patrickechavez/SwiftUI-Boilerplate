import SwiftUI

struct AuthFlowView: View {
    @ObservedObject var authRouter: Router
    @Environment(\.viewFactory) private var viewFactory
    @State private var authSheetRoute: AuthSheetRoute?

    var body: some View {
        NavigationStack(path: $authRouter.path) {
            if let factory = viewFactory {
                factory.makeAuthRootView(router: authRouter)
                    .navigationDestination(for: AuthRoute.self) { route in
                        factory.makeAuthRouteDestination(route, router: authRouter)
                    }
            } else {
                EmptyView()
                    .onAppear {
                        assertionFailure("ViewFactory not set in environment — auth flow will not render")
                    }
            }
        }
        .sheet(item: $authSheetRoute) { route in
            switch route {
            case .termsAndConditions:
                Text("Terms and Conditions")
            }
        }
        .environmentObject(authRouter)
    }
}
