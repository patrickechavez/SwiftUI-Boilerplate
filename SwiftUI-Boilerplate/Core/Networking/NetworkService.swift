import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private weak var tokenProvider: TokenProviding?

    init(session: URLSession = .shared, tokenProvider: TokenProviding? = nil) {
        self.session = session
        self.tokenProvider = tokenProvider
    }

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        var urlRequest = try buildRequest(from: endpoint)

        if let token = tokenProvider?.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError where error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
            throw NetworkError.noConnection
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 401, let provider = tokenProvider {
            try await provider.refreshTokens()

            var retryRequest = try buildRequest(from: endpoint)
            if let newToken = provider.accessToken {
                retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
            }

            let (retryData, retryResponse): (Data, URLResponse)
            do {
                (retryData, retryResponse) = try await session.data(for: retryRequest)
            } catch let error as URLError where error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
                throw NetworkError.noConnection
            }
            return try decode(data: retryData, response: retryResponse)
        }

        return try decode(data: data, response: httpResponse)
    }

    // Single photo — e.g. avatar, ID photo, thumbnail
    func upload<T: Decodable>(endpoint: Endpoint, imageData: Data, fileName: String, mimeType: String) async throws -> T {
        let image = MultipartImage(data: imageData, fileName: fileName, mimeType: mimeType, fieldName: "avatar")
        return try await upload(endpoint: endpoint, images: [image])
    }

    // Multiple photos — e.g. post gallery, product images, listing photos
    func upload<T: Decodable>(endpoint: Endpoint, images: [MultipartImage]) async throws -> T {
        var urlRequest = try buildMultipartRequest(from: endpoint, images: images)

        if let token = tokenProvider?.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: urlRequest)
        return try decode(data: data, response: response)
    }

    private func buildMultipartRequest(from endpoint: Endpoint, images: [MultipartImage]) throws -> URLRequest {
        let boundary = "Boundary-\(UUID().uuidString)"
        var components = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)

        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        endpoint.headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        var body = Data()
        for image in images {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(image.fieldName)\"; filename=\"\(image.fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(image.mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(image.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        return request
    }

    private func buildRequest(from endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(
            url: endpoint.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )

        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        return request
    }

    private func decode<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.clientError(statusCode: httpResponse.statusCode, data: data)
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
        default:
            throw NetworkError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
