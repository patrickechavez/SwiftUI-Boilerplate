import Foundation

@MainActor
final class Settings2ViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let router: any RouterProtocol

    init(router: any RouterProtocol) {
        self.router = router
    }

    func loadData() async {
        isLoading = true
        // Placeholder — add real logic later
        isLoading = false
    }

    func didTapNext() {
        router.push(Route.settings3)
    }
}
