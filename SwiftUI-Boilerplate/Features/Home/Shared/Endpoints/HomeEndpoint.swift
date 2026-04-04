import Foundation

enum HomeEndpoint: Endpoint {
    case list
    case detail(String)

    var path: String {
        switch self {
        case .list: return "/items"
        case .detail(let id): return "/items/\(id)"
        }
    }

    var method: HTTPMethod { .get }
}
