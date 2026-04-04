import Foundation

struct ItemDTO: Codable {
    let id: String
    let name: String
    let description: String

    func toDomain() -> Item {
        Item(id: id, name: name, description: description)
    }
}
