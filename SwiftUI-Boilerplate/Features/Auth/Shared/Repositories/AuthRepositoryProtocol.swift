import Foundation

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> AuthTokens
    func register(name: String, email: String, password: String) async throws -> AuthTokens
    func requestPasswordReset(email: String) async throws
    func verifyOTP(email: String, code: String) async throws -> AuthTokens
    func logout() async
}
