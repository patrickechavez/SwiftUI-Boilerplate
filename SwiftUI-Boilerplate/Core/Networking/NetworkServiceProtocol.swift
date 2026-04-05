import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
    func upload<T: Decodable>(endpoint: Endpoint, imageData: Data, fileName: String, mimeType: String) async throws -> T
    func upload<T: Decodable>(endpoint: Endpoint, images: [MultipartImage]) async throws -> T
}

struct MultipartImage {
    let data: Data
    let fileName: String
    let mimeType: String
    let fieldName: String
}
