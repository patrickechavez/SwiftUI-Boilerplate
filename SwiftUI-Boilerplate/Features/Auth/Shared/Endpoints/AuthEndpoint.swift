import Foundation

enum AuthEndpoint: Endpoint {
    case login(LoginRequest)
    case register(RegisterRequest)
    case requestPasswordReset(String)
    case verifyOTP(VerifyOTPRequest)
    case refresh(String)
    case logout(String)

    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .register: return "/auth/register"
        case .requestPasswordReset: return "/auth/password-reset"
        case .verifyOTP: return "/auth/verify-otp"
        case .refresh: return "/auth/refresh"
        case .logout: return "/auth/logout"
        }
    }

    var method: HTTPMethod { .post }

    var body: Encodable? {
        switch self {
        case .login(let request): return request
        case .register(let request): return request
        case .requestPasswordReset(let email): return ["email": email]
        case .verifyOTP(let request): return request
        case .refresh(let token): return ["refresh_token": token]
        case .logout(let token): return ["refresh_token": token]
        }
    }
}
