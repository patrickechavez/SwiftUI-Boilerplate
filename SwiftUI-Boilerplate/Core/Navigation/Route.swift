import Foundation

enum Route: Hashable {
    case itemDetail(id: String)
    case profile(userId: String)
    case settings
    case home2
    case home3
    case settings2
    case settings3
    case profile2
    case profile3
}

enum SheetRoute: Identifiable {
    case createItem
    case editItem(id: String)

    var id: String {
        switch self {
        case .createItem: return "createItem"
        case .editItem(let id): return "editItem-\(id)"
        }
    }
}

enum FullScreenCoverRoute: Identifiable {
    case imageViewer(url: URL)

    var id: String {
        switch self {
        case .imageViewer(let url): return url.absoluteString
        }
    }
}
