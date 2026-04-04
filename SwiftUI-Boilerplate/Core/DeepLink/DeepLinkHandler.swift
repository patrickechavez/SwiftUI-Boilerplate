import Foundation

protocol DeepLinkHandling {
    func parse(_ url: URL) -> DeepLink?
}

final class DeepLinkHandler: DeepLinkHandling {
    func parse(_ url: URL) -> DeepLink? {
        guard url.scheme == "myapp" else { return nil }
        guard let host = url.host else { return nil }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "dashboard":
            if pathComponents.count >= 2, pathComponents[0] == "item" {
                return .item(id: pathComponents[1])
            }
            return .dashboard
        case "settings":
            return .settings
        default:
            return nil
        }
    }
}
