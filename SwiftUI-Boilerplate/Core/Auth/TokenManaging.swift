import Foundation
import Combine

@MainActor
protocol TokenManaging: TokenProviding {
    var isLoggedIn: Bool { get }
    var isLoggedInPublisher: Published<Bool>.Publisher { get }
    func save(_ tokens: AuthTokens) throws
    func loadStoredTokens() -> AuthTokens?
    func clear()
    func refreshTokens() async throws
}
