import SwiftUI

@MainActor
final class DependencyContainer: DependencyContainerProtocol {

    // MARK: - Services

    private lazy var keychainService: KeychainServiceProtocol = KeychainService()
    private lazy var deepLinkHandler: DeepLinkHandling = DeepLinkHandler()

    private lazy var authNetworkService: NetworkServiceProtocol = NetworkService()

    private lazy var concreteTokenManager: TokenManager = TokenManager(
        keychainService: keychainService,
        networkService: authNetworkService
    )

    private lazy var tokenManager: any TokenManaging = concreteTokenManager

    private lazy var authService: AuthServiceProtocol = AuthService(
        networkService: authNetworkService
    )

    private lazy var authenticatedNetworkService: NetworkServiceProtocol = NetworkService(
        tokenProvider: concreteTokenManager
    )

    // MARK: - Repositories

    private lazy var authRepository: AuthRepositoryProtocol = AuthRepository(
        authService: authService,
        tokenManager: tokenManager
    )

    private lazy var homeRepository: HomeRepositoryProtocol = HomeRepository(
        networkService: authenticatedNetworkService
    )

    // MARK: - App Factories

    func makeAppCoordinator() -> AppCoordinator {
        AppCoordinator(
            tokenManager: tokenManager,
            authRepository: authRepository,
            deepLinkHandler: deepLinkHandler
        )
    }

    // MARK: - ViewFactory

    func makeRouteDestination(_ route: Route, router: any RouterProtocol) -> AnyView {
        switch route {
        case .itemDetail(let id):
            return AnyView(ItemDetailView(viewModel: self.makeItemDetailViewModel(id: id, router: router)))
        case .profile(let userId):
            return AnyView(Text("Profile: \(userId)"))
        case .settings:
            return AnyView(SettingsView(viewModel: self.makeSettingsViewModel(router: router)))
        case .home2:
            return AnyView(Home2View(viewModel: self.makeHome2ViewModel(router: router)))
        case .home3:
            return AnyView(Home3View(viewModel: self.makeHome3ViewModel(router: router)))
        case .settings2:
            return AnyView(Settings2View(viewModel: self.makeSettings2ViewModel(router: router)))
        case .settings3:
            return AnyView(Settings3View(viewModel: self.makeSettings3ViewModel(router: router)))
        case .profile2:
            return AnyView(Profile2View(viewModel: self.makeProfile2ViewModel(router: router)))
        case .profile3:
            return AnyView(Profile3View(viewModel: self.makeProfile3ViewModel(router: router)))
        }
    }

    func makeAuthRouteDestination(_ route: AuthRoute, router: any RouterProtocol) -> AnyView {
        switch route {
        case .register:
            return AnyView(RegisterView(viewModel: self.makeRegisterViewModel(router: router)))
        case .forgotPassword:
            return AnyView(ForgotPasswordView(viewModel: self.makeForgotPasswordViewModel(router: router)))
        case .otpVerification(let email):
            return AnyView(OTPVerificationView(viewModel: self.makeOTPVerificationViewModel(email: email)))
        }
    }

    func makeTabRootView(_ tab: AppTab, router: any RouterProtocol) -> AnyView {
        switch tab {
        case .home:
            return AnyView(HomeView(viewModel: self.makeHomeViewModel(router: router)))
        case .settings:
            return AnyView(SettingsView(viewModel: self.makeSettingsViewModel(router: router)))
        case .profile:
            return AnyView(ProfileView(viewModel: self.makeProfileViewModel(router: router)))
        }
    }

    func makeAuthRootView(router: any RouterProtocol) -> AnyView {
        return AnyView(LoginView(viewModel: self.makeLoginViewModel(router: router)))
    }

    // MARK: - ViewModel Factories

    private func makeLoginViewModel(router: any RouterProtocol) -> LoginViewModel {
        LoginViewModel(authRepository: authRepository, router: router)
    }

    private func makeRegisterViewModel(router: any RouterProtocol) -> RegisterViewModel {
        RegisterViewModel(authRepository: authRepository, router: router)
    }

    private func makeForgotPasswordViewModel(router: any RouterProtocol) -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(authRepository: authRepository, router: router)
    }

    private func makeOTPVerificationViewModel(email: String) -> OTPVerificationViewModel {
        OTPVerificationViewModel(email: email, authRepository: authRepository)
    }

    private func makeItemDetailViewModel(id: String, router: any RouterProtocol) -> ItemDetailViewModel {
        ItemDetailViewModel(itemId: id, repository: homeRepository, router: router)
    }

    // MARK: - Home Flow

    private func makeHomeViewModel(router: any RouterProtocol) -> HomeViewModel {
        HomeViewModel(repository: homeRepository, router: router)
    }

    private func makeHome2ViewModel(router: any RouterProtocol) -> Home2ViewModel {
        Home2ViewModel(router: router)
    }

    private func makeHome3ViewModel(router: any RouterProtocol) -> Home3ViewModel {
        Home3ViewModel(router: router)
    }

    // MARK: - Settings Flow

    private func makeSettingsViewModel(router: any RouterProtocol) -> SettingsViewModel {
        SettingsViewModel(authRepository: authRepository, router: router)
    }

    private func makeSettings2ViewModel(router: any RouterProtocol) -> Settings2ViewModel {
        Settings2ViewModel(router: router)
    }

    private func makeSettings3ViewModel(router: any RouterProtocol) -> Settings3ViewModel {
        Settings3ViewModel(router: router)
    }

    // MARK: - Profile Flow

    private func makeProfileViewModel(router: any RouterProtocol) -> ProfileViewModel {
        ProfileViewModel(router: router)
    }

    private func makeProfile2ViewModel(router: any RouterProtocol) -> Profile2ViewModel {
        Profile2ViewModel(router: router)
    }

    private func makeProfile3ViewModel(router: any RouterProtocol) -> Profile3ViewModel {
        Profile3ViewModel(router: router)
    }
}
