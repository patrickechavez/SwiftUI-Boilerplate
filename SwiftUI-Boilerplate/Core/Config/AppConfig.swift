import Foundation

enum AppConfig {
    static let baseURL: URL = {
        let raw = AppConfigValues.baseURL
        guard !raw.isEmpty, let url = URL(string: raw) else {
            preconditionFailure("BASE_URL is missing or malformed — check your .xcconfig file.")
        }
        return url
    }()

    static let apiVersion: String = {
        let version = AppConfigValues.apiVersion
        guard !version.isEmpty else {
            preconditionFailure("API_VERSION is missing — check your .xcconfig file.")
        }
        return version
    }()
}
