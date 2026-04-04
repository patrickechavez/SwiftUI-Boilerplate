import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol
    private let tokenManager: any TokenManaging

    init(authService: AuthServiceProtocol, tokenManager: any TokenManaging) {
        self.authService = authService
        self.tokenManager = tokenManager
    }

    func login(email: String, password: String) async throws -> AuthTokens {
        let tokens = try await authService.login(email: email, password: password)
        try await tokenManager.save(tokens)
        return tokens
    }

    func register(name: String, email: String, password: String) async throws -> AuthTokens {
        let tokens = try await authService.register(name: name, email: email, password: password)
        try await tokenManager.save(tokens)
        return tokens
    }

    func requestPasswordReset(email: String) async throws {
        try await authService.requestPasswordReset(email: email)
    }

    func verifyOTP(email: String, code: String) async throws -> AuthTokens {
        let tokens = try await authService.verifyOTP(email: email, code: code)
        try await tokenManager.save(tokens)
        return tokens
    }

    func logout() async {
        if let tokens = await tokenManager.loadStoredTokens() {
            try? await authService.logout(refreshToken: tokens.refreshToken)
        }
        await tokenManager.clear()
    }
}
