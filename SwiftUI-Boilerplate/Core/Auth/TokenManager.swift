import Foundation
import Combine

@MainActor
final class TokenManager: ObservableObject, TokenManaging {
    private let keychainService: KeychainServiceProtocol
    private let networkService: NetworkServiceProtocol
    private var currentTokens: AuthTokens?
    private var refreshTask: Task<AuthTokens, Error>?

    @Published var isLoggedIn: Bool = false

    var isLoggedInPublisher: Published<Bool>.Publisher { $isLoggedIn }

    var accessToken: String? {
        guard let tokens = currentTokens, !tokens.isExpired else {
            return nil
        }
        return tokens.accessToken
    }

    init(keychainService: KeychainServiceProtocol, networkService: NetworkServiceProtocol) {
        self.keychainService = keychainService
        self.networkService = networkService
    }

    func save(_ tokens: AuthTokens) throws {
        try keychainService.save(tokens.toDTO(), for: KeychainKey.accessToken)
        currentTokens = tokens
        isLoggedIn = !tokens.isExpired
    }

    func loadStoredTokens() -> AuthTokens? {
        do {
            guard let dto = try keychainService.load(AuthTokensDTO.self, for: KeychainKey.accessToken) else {
                return nil
            }
            let tokens = try dto.toDomain()
            currentTokens = tokens
            isLoggedIn = !tokens.isExpired
            return tokens
        } catch {
            return nil
        }
    }

    func clear() {
        do {
            try keychainService.delete(for: KeychainKey.accessToken)
        } catch {
            // Log error in production — keychain delete failed during logout
        }
        currentTokens = nil
        isLoggedIn = false
    }

    func refreshTokens() async throws {
        if let existingTask = refreshTask {
            _ = try await existingTask.value
            return
        }

        guard let refreshToken = currentTokens?.refreshToken else {
            throw AuthError.noRefreshToken
        }

        let task = Task<AuthTokens, Error> {
            let dto: AuthTokensDTO = try await networkService.request(
                endpoint: AuthEndpoint.refresh(refreshToken)
            )
            let newTokens = try dto.toDomain()
            try keychainService.save(dto, for: KeychainKey.accessToken)
            currentTokens = newTokens
            isLoggedIn = !newTokens.isExpired
            return newTokens
        }

        refreshTask = task

        do {
            _ = try await task.value
            refreshTask = nil
        } catch {
            refreshTask = nil
            throw error
        }
    }
}
