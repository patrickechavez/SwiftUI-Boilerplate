import Foundation

protocol KeychainServiceProtocol {
    func save(_ data: Data, for key: String) throws
    func load(for key: String) throws -> Data?
    func delete(for key: String) throws
}

extension KeychainServiceProtocol {
    func save<T: Encodable>(_ value: T, for key: String) throws {
        let data = try JSONEncoder().encode(value)
        try save(data, for: key)
    }

    func load<T: Decodable>(_ type: T.Type, for key: String) throws -> T? {
        guard let data = try load(for: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum KeychainKey {
    static let accessToken = "access_token"
}
