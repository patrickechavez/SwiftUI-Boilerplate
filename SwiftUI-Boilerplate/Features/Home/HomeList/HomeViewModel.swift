import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: HomeRepositoryProtocol
    private let router: any RouterProtocol
    private var currentTask: Task<Void, Never>?

    init(repository: HomeRepositoryProtocol, router: any RouterProtocol) {
        self.repository = repository
        self.router = router
    }

    deinit {
        currentTask?.cancel()
    }

    func loadItems() {
        guard !isLoading else { return }

        currentTask?.cancel()
        currentTask = Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                items = try await repository.fetchItems()
            } catch is CancellationError {
                return
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred."
            }
        }
    }

    func didSelectItem(_ item: Item) {
        router.push(Route.itemDetail(id: item.id))
    }

    func didTapCreateItem() {
        router.presentSheet(.createItem)
    }

    func didTapHome2() {
        router.push(Route.home2)
    }
}
