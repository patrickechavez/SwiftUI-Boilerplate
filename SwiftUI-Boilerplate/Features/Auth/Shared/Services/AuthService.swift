import Foundation

final class AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func login(email: String, password: String) async throws -> AuthTokens {
        let request = LoginRequest(email: email, password: password)
        let dto: AuthTokensDTO = try await networkService.request(
            endpoint: AuthEndpoint.login(request)
        )
        return try dto.toDomain()
    }

    func register(name: String, email: String, password: String) async throws -> AuthTokens {
        let request = RegisterRequest(name: name, email: email, password: password)
        let dto: AuthTokensDTO = try await networkService.request(
            endpoint: AuthEndpoint.register(request)
        )
        return try dto.toDomain()
    }

    func requestPasswordReset(email: String) async throws {
        let _: EmptyResponse = try await networkService.request(
            endpoint: AuthEndpoint.requestPasswordReset(email)
        )
    }

    func verifyOTP(email: String, code: String) async throws -> AuthTokens {
        let request = VerifyOTPRequest(email: email, code: code)
        let dto: AuthTokensDTO = try await networkService.request(
            endpoint: AuthEndpoint.verifyOTP(request)
        )
        return try dto.toDomain()
    }

    func logout(refreshToken: String) async throws {
        let _: EmptyResponse = try await networkService.request(
            endpoint: AuthEndpoint.logout(refreshToken)
        )
    }
}
