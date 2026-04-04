import Foundation

enum AppTab: String, CaseIterable, Hashable {
    case home
    case settings
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .settings: return "Settings"
        case .profile: return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .settings: return "gear"
        case .profile: return "person"
        }
    }
}
