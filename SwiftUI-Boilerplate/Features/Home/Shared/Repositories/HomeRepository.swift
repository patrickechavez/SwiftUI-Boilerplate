import Foundation

final class HomeRepository: HomeRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchItems() async throws -> [Item] {
        let dtos: [ItemDTO] = try await networkService.request(endpoint: HomeEndpoint.list)
        return dtos.map { $0.toDomain() }
    }

    func fetchItem(id: String) async throws -> Item {
        let dto: ItemDTO = try await networkService.request(endpoint: HomeEndpoint.detail(id))
        return dto.toDomain()
    }
}
