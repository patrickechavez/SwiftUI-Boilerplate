import Foundation

struct VerifyOTPRequest: Encodable {
    let email: String
    let code: String
}
