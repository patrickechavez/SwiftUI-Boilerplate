import Foundation

struct AuthTokens: Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    var isExpired: Bool {
        Date().addingTimeInterval(30) >= expiresAt
    }

    func toDTO() -> AuthTokensDTO {
        AuthTokensDTO(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }
}
