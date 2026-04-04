import Foundation

protocol HomeRepositoryProtocol {
    func fetchItems() async throws -> [Item]
    func fetchItem(id: String) async throws -> Item
}
