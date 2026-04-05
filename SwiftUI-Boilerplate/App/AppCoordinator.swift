import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    @Published var selectedTab: AppTab = .home

    private let tokenManager: any TokenManaging
    private var cancellables = Set<AnyCancellable>()

    let authRouter = Router()
    let routers: [AppTab: Router]

    init(tokenManager: any TokenManaging) {
        self.tokenManager = tokenManager
        self.routers = Dictionary(uniqueKeysWithValues: AppTab.allCases.map { ($0, Router()) })

        tokenManager.isLoggedInPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loggedIn in
                guard let self else { return }
                if loggedIn {
                    self.authRouter.popToRoot()
                    self.isAuthenticated = true
                } else {
                    self.isAuthenticated = false
                    self.routers.values.forEach { $0.popToRoot() }
                }
            }
            .store(in: &cancellables)
    }

    func checkAuthOnLaunch() async {
        isCheckingAuth = true
        isAuthenticated = tokenManager.loadStoredTokens() != nil
        isCheckingAuth = false
    }
}
