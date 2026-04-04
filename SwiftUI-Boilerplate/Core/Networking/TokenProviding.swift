import Foundation

protocol TokenProviding: AnyObject {
    var accessToken: String? { get }
    func refreshTokens() async throws
}
