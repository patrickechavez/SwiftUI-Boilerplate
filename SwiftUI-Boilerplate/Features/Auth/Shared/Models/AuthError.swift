import Foundation

enum AuthError: LocalizedError {
    case noRefreshToken
    case invalidCredentials
    case invalidTokens

    var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "No refresh token available"
        case .invalidCredentials:
            return "Invalid credentials"
        case .invalidTokens:
            return "Invalid authentication tokens received"
        }
    }
}
