import Foundation

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Encodable? { get }
    var queryItems: [URLQueryItem]? { get }
}

private enum EndpointDefaults {
    static let baseURL: URL = {
        guard let url = URL(string: "https://api.example.com") else {
            preconditionFailure("Default base URL is malformed — this should never happen.")
        }
        return url
    }()
}

extension Endpoint {
    var baseURL: URL { EndpointDefaults.baseURL }
    var headers: [String: String]? { nil }
    var body: Encodable? { nil }
    var queryItems: [URLQueryItem]? { nil }
}
