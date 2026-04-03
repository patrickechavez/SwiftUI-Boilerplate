import SwiftUI

@MainActor
final class Router: RouterProtocol {
    @Published var path = NavigationPath()
    @Published var sheetRoute: SheetRoute?
    @Published var fullScreenCoverRoute: FullScreenCoverRoute?

    func push<T: Hashable>(_ route: T) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func presentSheet(_ route: SheetRoute) {
        sheetRoute = route
    }

    func presentFullScreenCover(_ route: FullScreenCoverRoute) {
        fullScreenCoverRoute = route
    }

    func dismissSheet() {
        sheetRoute = nil
    }

    func dismissFullScreenCover() {
        fullScreenCoverRoute = nil
    }
}
