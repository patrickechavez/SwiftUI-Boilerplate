import Foundation

@MainActor
final class ItemDetailViewModel: ObservableObject {
    @Published var item: Item?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let itemId: String
    private let repository: HomeRepositoryProtocol
    private let router: any RouterProtocol
    private var currentTask: Task<Void, Never>?

    init(itemId: String, repository: HomeRepositoryProtocol, router: any RouterProtocol) {
        self.itemId = itemId
        self.repository = repository
        self.router = router
    }

    deinit {
        currentTask?.cancel()
    }

    func loadItem() {
        guard !isLoading else { return }

        currentTask?.cancel()
        currentTask = Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                item = try await repository.fetchItem(id: itemId)
            } catch is CancellationError {
                return
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred."
            }
        }
    }

    func didTapEdit() {
        guard let item = item else { return }
        router.presentSheet(.editItem(id: item.id))
    }
}
