import SwiftUI

@MainActor
protocol RouterProtocol: ObservableObject {
    var path: NavigationPath { get set }
    var sheetRoute: SheetRoute? { get set }
    var fullScreenCoverRoute: FullScreenCoverRoute? { get set }

    func push<T: Hashable>(_ route: T)
    func pop()
    func popToRoot()
    func presentSheet(_ route: SheetRoute)
    func presentFullScreenCover(_ route: FullScreenCoverRoute)
    func dismissSheet()
    func dismissFullScreenCover()
}
