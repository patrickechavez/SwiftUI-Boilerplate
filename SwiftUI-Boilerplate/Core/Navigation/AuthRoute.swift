import Foundation

enum AuthRoute: Hashable {
    case register
    case forgotPassword
    case otpVerification(email: String)
}

enum AuthSheetRoute: Identifiable {
    case termsAndConditions

    var id: String {
        switch self {
        case .termsAndConditions: return "terms"
        }
    }
}
