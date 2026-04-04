import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case invalidURL
    case noConnection
    case unauthorized
    case clientError(statusCode: Int, data: Data)
    case serverError(statusCode: Int, data: Data)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .invalidURL:
            return "Invalid URL"
        case .noConnection:
            return "No internet connection"
        case .unauthorized:
            return "Session expired. Please log in again."
        case .clientError(let statusCode, _):
            return "Request error (\(statusCode))"
        case .serverError(let statusCode, _):
            return "Server error (\(statusCode))"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
