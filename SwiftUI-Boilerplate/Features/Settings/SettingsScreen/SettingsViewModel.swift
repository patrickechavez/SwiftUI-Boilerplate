import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isLoggingOut = false

    private let authRepository: AuthRepositoryProtocol
    private let router: any RouterProtocol

    init(authRepository: AuthRepositoryProtocol, router: any RouterProtocol) {
        self.authRepository = authRepository
        self.router = router
    }

    func didTapSettings2() {
        router.push(Route.settings2)
    }

    func logout() async {
        isLoggingOut = true
        await authRepository.logout()
        isLoggingOut = false
    }
}
