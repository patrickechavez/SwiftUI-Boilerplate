import Foundation

enum DeepLink: Equatable {
    case dashboard
    case item(id: String)
    case settings
}
