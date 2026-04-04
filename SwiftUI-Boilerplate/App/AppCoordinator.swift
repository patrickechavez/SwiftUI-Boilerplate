import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    @Published var selectedTab: AppTab = .home

    private let tokenManager: any TokenManaging
    private let deepLinkHandler: DeepLinkHandling
    private var cancellables = Set<AnyCancellable>()
    private var pendingDeepLink: DeepLink?

    let authRouter = Router()
    let routers: [AppTab: Router]

    init(tokenManager: any TokenManaging, deepLinkHandler: DeepLinkHandling) {
        self.tokenManager = tokenManager
        self.deepLinkHandler = deepLinkHandler
        self.routers = Dictionary(uniqueKeysWithValues: AppTab.allCases.map { ($0, Router()) })

        tokenManager.isLoggedInPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loggedIn in
                guard let self else { return }
                if loggedIn {
                    self.authRouter.popToRoot()
                    self.isAuthenticated = true
                    self.processPendingDeepLink()
                } else {
                    self.isAuthenticated = false
                    self.routers.values.forEach { $0.popToRoot() }
                }
            }
            .store(in: &cancellables)
    }

    func checkAuthOnLaunch() async {
        isCheckingAuth = true
        isAuthenticated = await tokenManager.loadStoredTokens() != nil
        isCheckingAuth = false
    }

    func handleDeepLink(_ url: URL) {
        guard let deepLink = deepLinkHandler.parse(url) else { return }

        if isAuthenticated {
            navigate(to: deepLink)
        } else {
            pendingDeepLink = deepLink
        }
    }

    // MARK: - Private

    private func processPendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        navigate(to: deepLink)
    }

    private func navigate(to deepLink: DeepLink) {
        switch deepLink {
        case .dashboard:
            selectedTab = .home
        case .item(let id):
            selectedTab = .home
            routers[.home]?.popToRoot()
            routers[.home]?.push(Route.itemDetail(id: id))
        case .settings:
            selectedTab = .settings
        }
    }
}
