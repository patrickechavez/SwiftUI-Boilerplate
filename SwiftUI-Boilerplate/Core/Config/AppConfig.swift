import Foundation

enum AppConfig {
    static let baseURL: URL = {
        guard
            let urlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
            !urlString.isEmpty,
            let url = URL(string: urlString)
        else {
            preconditionFailure("BASE_URL is missing or malformed in Info.plist — check your .xcconfig file.")
        }
        return url
    }()

    static let apiVersion: String = {
        guard
            let version = Bundle.main.infoDictionary?["API_VERSION"] as? String,
            !version.isEmpty
        else {
            preconditionFailure("API_VERSION is missing in Info.plist — check your .xcconfig file.")
        }
        return version
    }()
}
