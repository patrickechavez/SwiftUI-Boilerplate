import Foundation

struct AuthTokensDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
    }

    func toDomain() throws -> AuthTokens {
        guard !accessToken.isEmpty, !refreshToken.isEmpty else {
            throw AuthError.invalidTokens
        }
        return AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }
}
