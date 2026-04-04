# SOLID & Production Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the SwiftUI-Boilerplate into a production-grade, fully testable app template with protocol-based DI, safe error handling, and hardened token management.

**Architecture:** Protocol-first refactor of existing MVVM architecture. Extract protocols for Router and DependencyContainer. Harden TokenManager with refresh mutex and expiry. Add unit test target with mocks for all protocols.

**Tech Stack:** Swift, SwiftUI, Combine, XCTest, Security framework (Keychain)

---

### Task 1: Extract RouterProtocol

**Files:**
- Create: `SwiftUI-Boilerplate/Core/Navigation/RouterProtocol.swift`
- Modify: `SwiftUI-Boilerplate/Core/Navigation/Router.swift`

- [ ] **Step 1: Create `RouterProtocol.swift`**

```swift
import SwiftUI

@MainActor
protocol RouterProtocol: ObservableObject {
    var path: NavigationPath { get set }
    var sheetRoute: SheetRoute? { get set }
    var fullScreenCoverRoute: FullScreenCoverRoute? { get set }

    func push<T: Hashable>(_ route: T)
    func pop()
    func popToRoot()
    func presentSheet(_ route: SheetRoute)
    func presentFullScreenCover(_ route: FullScreenCoverRoute)
    func dismissSheet()
    func dismissFullScreenCover()
}
```

- [ ] **Step 2: Add conformance to `Router.swift`**

Change:
```swift
@MainActor
final class Router: ObservableObject {
```
To:
```swift
@MainActor
final class Router: RouterProtocol {
```

- [ ] **Step 3: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add SwiftUI-Boilerplate/Core/Navigation/RouterProtocol.swift SwiftUI-Boilerplate/Core/Navigation/Router.swift
git commit -m "feat: extract RouterProtocol from Router"
```

---

### Task 2: Update all ViewModels to depend on RouterProtocol

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Auth/Login/LoginViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/Register/RegisterViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/ForgotPassword/ForgotPasswordViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Home/HomeList/HomeViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Home/ItemDetail/ItemDetailViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Home/Home2/Home2ViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Home/Home3/Home3ViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Settings/SettingsScreen/SettingsViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Settings/Settings2/Settings2ViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Settings/Settings3/Settings3ViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Profile/ProfileScreen/ProfileViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Profile/Profile2/Profile2ViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Profile/Profile3/Profile3ViewModel.swift`

- [ ] **Step 1: Update `LoginViewModel.swift`**

Change:
```swift
    private let router: Router

    init(authRepository: AuthRepositoryProtocol, router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(authRepository: AuthRepositoryProtocol, router: any RouterProtocol) {
```

- [ ] **Step 2: Update `RegisterViewModel.swift`**

Change:
```swift
    private let router: Router

    init(authRepository: AuthRepositoryProtocol, router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(authRepository: AuthRepositoryProtocol, router: any RouterProtocol) {
```

- [ ] **Step 3: Update `ForgotPasswordViewModel.swift`**

Change:
```swift
    private let router: Router

    init(authRepository: AuthRepositoryProtocol, router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(authRepository: AuthRepositoryProtocol, router: any RouterProtocol) {
```

- [ ] **Step 4: Update `HomeViewModel.swift`**

Change:
```swift
    private let router: Router

    init(repository: HomeRepositoryProtocol, router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(repository: HomeRepositoryProtocol, router: any RouterProtocol) {
```

- [ ] **Step 5: Update `ItemDetailViewModel.swift`**

Change:
```swift
    private let router: Router

    init(itemId: String, repository: HomeRepositoryProtocol, router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(itemId: String, repository: HomeRepositoryProtocol, router: any RouterProtocol) {
```

- [ ] **Step 6: Update `Home2ViewModel.swift`**

Change:
```swift
    private let router: Router

    init(router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(router: any RouterProtocol) {
```

- [ ] **Step 7: Update `Home3ViewModel.swift`**

Change:
```swift
    private let router: Router

    init(router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(router: any RouterProtocol) {
```

- [ ] **Step 8: Update `SettingsViewModel.swift`**

Change:
```swift
    private let router: Router

    init(authRepository: AuthRepositoryProtocol, router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(authRepository: AuthRepositoryProtocol, router: any RouterProtocol) {
```

- [ ] **Step 9: Update `Settings2ViewModel.swift`**

Change:
```swift
    private let router: Router

    init(router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(router: any RouterProtocol) {
```

- [ ] **Step 10: Update `Settings3ViewModel.swift`**

Change:
```swift
    private let router: Router

    init(router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(router: any RouterProtocol) {
```

- [ ] **Step 11: Update `ProfileViewModel.swift`**

Change:
```swift
    private let router: Router

    init(router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(router: any RouterProtocol) {
```

- [ ] **Step 12: Update `Profile2ViewModel.swift`**

Change:
```swift
    private let router: Router

    init(router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(router: any RouterProtocol) {
```

- [ ] **Step 13: Update `Profile3ViewModel.swift`**

Change:
```swift
    private let router: Router

    init(router: Router) {
```
To:
```swift
    private let router: any RouterProtocol

    init(router: any RouterProtocol) {
```

- [ ] **Step 14: Update `ViewFactory.swift` protocol to use `any RouterProtocol`**

Change:
```swift
@MainActor
protocol ViewFactory {
    @ViewBuilder func makeRouteDestination(_ route: Route, router: Router) -> AnyView
    @ViewBuilder func makeAuthRouteDestination(_ route: AuthRoute, router: Router) -> AnyView
    @ViewBuilder func makeTabRootView(_ tab: AppTab, router: Router) -> AnyView
    @ViewBuilder func makeAuthRootView(router: Router) -> AnyView
}
```
To:
```swift
@MainActor
protocol ViewFactory {
    @ViewBuilder func makeRouteDestination(_ route: Route, router: any RouterProtocol) -> AnyView
    @ViewBuilder func makeAuthRouteDestination(_ route: AuthRoute, router: any RouterProtocol) -> AnyView
    @ViewBuilder func makeTabRootView(_ tab: AppTab, router: any RouterProtocol) -> AnyView
    @ViewBuilder func makeAuthRootView(router: any RouterProtocol) -> AnyView
}
```

- [ ] **Step 15: Update `DependencyContainer.swift` factory method signatures**

Update all `ViewFactory` method signatures and private ViewModel factory methods to accept `any RouterProtocol` instead of `Router`:

```swift
    // ViewFactory conformance
    func makeRouteDestination(_ route: Route, router: any RouterProtocol) -> AnyView { ... }
    func makeAuthRouteDestination(_ route: AuthRoute, router: any RouterProtocol) -> AnyView { ... }
    func makeTabRootView(_ tab: AppTab, router: any RouterProtocol) -> AnyView { ... }
    func makeAuthRootView(router: any RouterProtocol) -> AnyView { ... }

    // Private ViewModel factories
    private func makeLoginViewModel(router: any RouterProtocol) -> LoginViewModel { ... }
    private func makeRegisterViewModel(router: any RouterProtocol) -> RegisterViewModel { ... }
    private func makeForgotPasswordViewModel(router: any RouterProtocol) -> ForgotPasswordViewModel { ... }
    private func makeItemDetailViewModel(id: String, router: any RouterProtocol) -> ItemDetailViewModel { ... }
    private func makeHomeViewModel(router: any RouterProtocol) -> HomeViewModel { ... }
    private func makeHome2ViewModel(router: any RouterProtocol) -> Home2ViewModel { ... }
    private func makeHome3ViewModel(router: any RouterProtocol) -> Home3ViewModel { ... }
    private func makeSettingsViewModel(router: any RouterProtocol) -> SettingsViewModel { ... }
    private func makeSettings2ViewModel(router: any RouterProtocol) -> Settings2ViewModel { ... }
    private func makeSettings3ViewModel(router: any RouterProtocol) -> Settings3ViewModel { ... }
    private func makeProfileViewModel(router: any RouterProtocol) -> ProfileViewModel { ... }
    private func makeProfile2ViewModel(router: any RouterProtocol) -> Profile2ViewModel { ... }
    private func makeProfile3ViewModel(router: any RouterProtocol) -> Profile3ViewModel { ... }
```

- [ ] **Step 16: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 17: Commit**

```bash
git add -A
git commit -m "refactor: update all ViewModels to depend on RouterProtocol"
```

---

### Task 3: Extract DependencyContainerProtocol and remove singleton

**Files:**
- Create: `SwiftUI-Boilerplate/Core/DI/DependencyContainerProtocol.swift`
- Modify: `SwiftUI-Boilerplate/Core/DI/DependencyContainer.swift`
- Modify: `SwiftUI-Boilerplate/App/SwiftUI_BoilerplateApp.swift`

- [ ] **Step 1: Create `DependencyContainerProtocol.swift`**

```swift
import Foundation

@MainActor
protocol DependencyContainerProtocol: ViewFactory {
    var tokenManager: any TokenManaging { get }
    func makeAppCoordinator() -> AppCoordinator
}
```

- [ ] **Step 2: Refactor `DependencyContainer.swift` — remove singleton, conform to protocol**

Replace the full file with:

```swift
import SwiftUI

@MainActor
final class DependencyContainer: DependencyContainerProtocol {

    // MARK: - Services

    private lazy var keychainService: KeychainServiceProtocol = KeychainService()
    private lazy var deepLinkHandler: DeepLinkHandling = DeepLinkHandler()

    private lazy var authNetworkService: NetworkServiceProtocol = NetworkService()

    private(set) lazy var tokenManager: any TokenManaging = TokenManager(
        keychainService: keychainService,
        networkService: authNetworkService
    )

    private lazy var authService: AuthServiceProtocol = AuthService(
        networkService: authNetworkService
    )

    private lazy var authenticatedNetworkService: NetworkServiceProtocol = NetworkService(
        tokenProvider: tokenManager as? TokenProviding
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
            AnyView(ItemDetailView(viewModel: makeItemDetailViewModel(id: id, router: router)))
        case .profile(let userId):
            AnyView(Text("Profile: \(userId)"))
        case .settings:
            AnyView(SettingsView(viewModel: makeSettingsViewModel(router: router)))
        case .home2:
            AnyView(Home2View(viewModel: makeHome2ViewModel(router: router)))
        case .home3:
            AnyView(Home3View(viewModel: makeHome3ViewModel(router: router)))
        case .settings2:
            AnyView(Settings2View(viewModel: makeSettings2ViewModel(router: router)))
        case .settings3:
            AnyView(Settings3View(viewModel: makeSettings3ViewModel(router: router)))
        case .profile2:
            AnyView(Profile2View(viewModel: makeProfile2ViewModel(router: router)))
        case .profile3:
            AnyView(Profile3View(viewModel: makeProfile3ViewModel(router: router)))
        }
    }

    func makeAuthRouteDestination(_ route: AuthRoute, router: any RouterProtocol) -> AnyView {
        switch route {
        case .register:
            AnyView(RegisterView(viewModel: makeRegisterViewModel(router: router)))
        case .forgotPassword:
            AnyView(ForgotPasswordView(viewModel: makeForgotPasswordViewModel(router: router)))
        case .otpVerification(let email):
            AnyView(OTPVerificationView(viewModel: makeOTPVerificationViewModel(email: email)))
        }
    }

    func makeTabRootView(_ tab: AppTab, router: any RouterProtocol) -> AnyView {
        switch tab {
        case .home:
            AnyView(HomeView(viewModel: makeHomeViewModel(router: router)))
        case .settings:
            AnyView(SettingsView(viewModel: makeSettingsViewModel(router: router)))
        case .profile:
            AnyView(ProfileView(viewModel: makeProfileViewModel(router: router)))
        }
    }

    func makeAuthRootView(router: any RouterProtocol) -> AnyView {
        AnyView(LoginView(viewModel: makeLoginViewModel(router: router)))
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
```

- [ ] **Step 3: Update `SwiftUI_BoilerplateApp.swift` to create container without singleton**

Replace the full file with:

```swift
import SwiftUI

@main
struct SwiftUI_BoilerplateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var coordinator: AppCoordinator

    private let container: DependencyContainer

    init() {
        let container = DependencyContainer()
        self.container = container
        _coordinator = StateObject(wrappedValue: container.makeAppCoordinator())
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if coordinator.isCheckingAuth {
                    ProgressView("Loading...")
                } else if coordinator.isAuthenticated {
                    MainTabView()
                } else {
                    AuthFlowView(authRouter: coordinator.authRouter)
                }
            }
            .environment(\.viewFactory, container)
            .environmentObject(coordinator)
            .onOpenURL { url in
                coordinator.handleDeepLink(url)
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveDeepLink)) { notification in
                if let url = notification.userInfo?["url"] as? URL {
                    coordinator.handleDeepLink(url)
                }
            }
            .task {
                await coordinator.checkAuthOnLaunch()
            }
        }
    }
}
```

- [ ] **Step 4: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor: extract DependencyContainerProtocol, remove singleton"
```

---

### Task 4: Remove force-unwraps and add safe navigation

**Files:**
- Modify: `SwiftUI-Boilerplate/Core/Navigation/View+Navigation.swift`
- Modify: `SwiftUI-Boilerplate/Features/Dashboard/MainTabView.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/AuthFlowView.swift`

- [ ] **Step 1: Fix `View+Navigation.swift` — remove `viewFactory!`**

Replace the full file with:

```swift
import SwiftUI

struct RouterNavigationModifier: ViewModifier {
    @EnvironmentObject private var router: Router
    @Environment(\.viewFactory) private var viewFactory

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Route.self) { route in
                if let factory = viewFactory {
                    factory.makeRouteDestination(route, router: router)
                } else {
                    EmptyView()
                }
            }
            .sheet(item: $router.sheetRoute) { route in
                switch route {
                case .createItem:
                    Text("Create Item")
                case .editItem(let id):
                    Text("Edit Item: \(id)")
                }
            }
            .fullScreenCover(item: $router.fullScreenCoverRoute) { route in
                switch route {
                case .imageViewer(let url):
                    VStack {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        Button("Dismiss") {
                            router.dismissFullScreenCover()
                        }
                        .padding()
                    }
                }
            }
    }
}

extension View {
    func withRouter() -> some View {
        modifier(RouterNavigationModifier())
    }
}
```

- [ ] **Step 2: Fix `MainTabView.swift` — remove force-unwraps**

Replace the full file with:

```swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                if let router = coordinator.routers[tab] {
                    TabContentWrapper(
                        router: router,
                        tab: tab
                    )
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
                }
            }
        }
    }
}

private struct TabContentWrapper: View {
    @ObservedObject var router: Router
    @Environment(\.viewFactory) private var viewFactory
    let tab: AppTab

    var body: some View {
        NavigationStack(path: $router.path) {
            if let factory = viewFactory {
                factory.makeTabRootView(tab, router: router)
                    .withRouter()
            }
        }
        .sheet(item: $router.sheetRoute) { route in
            sheetContent(for: route)
        }
        .fullScreenCover(item: $router.fullScreenCoverRoute) { route in
            fullScreenContent(for: route)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    private func sheetContent(for route: SheetRoute) -> some View {
        switch route {
        case .createItem:
            Text("Create Item")
        case .editItem(let id):
            Text("Edit Item: \(id)")
        }
    }

    @ViewBuilder
    private func fullScreenContent(for route: FullScreenCoverRoute) -> some View {
        switch route {
        case .imageViewer(let url):
            VStack {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                Button("Dismiss") {
                    router.dismissFullScreenCover()
                }
                .padding()
            }
        }
    }
}
```

- [ ] **Step 3: Fix `AuthFlowView.swift` — remove force-unwraps**

Replace the full file with:

```swift
import SwiftUI

struct AuthFlowView: View {
    @ObservedObject var authRouter: Router
    @Environment(\.viewFactory) private var viewFactory
    @State private var authSheetRoute: AuthSheetRoute?

    var body: some View {
        NavigationStack(path: $authRouter.path) {
            Group {
                if let factory = viewFactory {
                    factory.makeAuthRootView(router: authRouter)
                        .navigationDestination(for: AuthRoute.self) { route in
                            factory.makeAuthRouteDestination(route, router: authRouter)
                        }
                }
            }
        }
        .sheet(item: $authSheetRoute) { route in
            switch route {
            case .termsAndConditions:
                Text("Terms and Conditions")
            }
        }
        .environmentObject(authRouter)
    }
}
```

- [ ] **Step 4: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "fix: remove all force-unwraps in navigation layer"
```

---

### Task 5: Expand NetworkError and improve error mapping

**Files:**
- Modify: `SwiftUI-Boilerplate/Core/Networking/NetworkError.swift`
- Modify: `SwiftUI-Boilerplate/Core/Networking/NetworkService.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Models/AuthError.swift`

- [ ] **Step 1: Expand `NetworkError.swift`**

Replace the full file with:

```swift
import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case invalidURL
    case noConnection
    case unauthorized
    case clientError(statusCode: Int, data: Data)
    case serverError(statusCode: Int, data: Data)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .invalidURL:
            return "Invalid URL"
        case .noConnection:
            return "No internet connection"
        case .unauthorized:
            return "Session expired. Please log in again."
        case .clientError(let statusCode, _):
            return "Request error (\(statusCode))"
        case .serverError(let statusCode, _):
            return "Server error (\(statusCode))"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
```

- [ ] **Step 2: Update `NetworkService.swift` decode method to use new error types**

Replace the `decode` method:

```swift
    private func decode<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.clientError(statusCode: httpResponse.statusCode, data: data)
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
        default:
            throw NetworkError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
```

Also update the `buildRequest` method to throw `.invalidURL` instead of `.invalidResponse`:

Change:
```swift
        guard let url = components?.url else {
            throw NetworkError.invalidResponse
        }
```
To:
```swift
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
```

Also wrap the `session.data(for:)` call to detect no-connection errors. Update the `request` method's first network call:

Change:
```swift
        let (data, response) = try await session.data(for: urlRequest)
```
To:
```swift
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError where error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
            throw NetworkError.noConnection
        }
```

- [ ] **Step 3: Add `invalidTokens` case to `AuthError.swift`**

Add a new case:

```swift
enum AuthError: LocalizedError {
    case noRefreshToken
    case invalidCredentials
    case invalidTokens

    var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "No refresh token available"
        case .invalidCredentials:
            return "Invalid credentials"
        case .invalidTokens:
            return "Invalid authentication tokens received"
        }
    }
}
```

- [ ] **Step 4: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: expand NetworkError types, add connection and server error handling"
```

---

### Task 6: Harden KeychainService

**Files:**
- Modify: `SwiftUI-Boilerplate/Core/Keychain/KeychainService.swift`
- Modify: `SwiftUI-Boilerplate/Core/Keychain/KeychainError.swift`

- [ ] **Step 1: Add `dataConversionFailed` to `KeychainError.swift`**

```swift
import Foundation

enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case dataConversionFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Keychain save failed with status: \(status)"
        case .loadFailed(let status):
            return "Keychain load failed with status: \(status)"
        case .deleteFailed(let status):
            return "Keychain delete failed with status: \(status)"
        case .dataConversionFailed:
            return "Failed to convert keychain data"
        }
    }
}
```

- [ ] **Step 2: Refactor `KeychainService.swift` — atomic save, access control**

Replace the full file with:

```swift
import Foundation
import Security

final class KeychainService: KeychainServiceProtocol {
    private let serviceName: String

    init(serviceName: String = Bundle.main.bundleIdentifier ?? "com.app") {
        self.serviceName = serviceName
    }

    func save(_ data: Data, for key: String) throws {
        let matchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let updateAttributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(matchQuery as CFDictionary, updateAttributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            var addQuery = matchQuery
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.saveFailed(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.saveFailed(updateStatus)
        }
    }

    func load(for key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw KeychainError.loadFailed(status)
        }

        return result as? Data
    }

    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}
```

- [ ] **Step 3: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: harden KeychainService with atomic save and access control"
```

---

### Task 7: Harden TokenManager — refresh mutex, expiry, derived state

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Models/AuthTokens.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/DTOs/AuthTokensDTO.swift`
- Modify: `SwiftUI-Boilerplate/Core/Auth/TokenManaging.swift`
- Modify: `SwiftUI-Boilerplate/Core/Auth/TokenManager.swift`

- [ ] **Step 1: Add expiry to `AuthTokens.swift`**

Replace the full file with:

```swift
import Foundation

struct AuthTokens: Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    var isExpired: Bool {
        Date() >= expiresAt
    }

    func toDTO() -> AuthTokensDTO {
        AuthTokensDTO(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }
}
```

- [ ] **Step 2: Update `AuthTokensDTO.swift` with expiry and CodingKeys**

Replace the full file with:

```swift
import Foundation

struct AuthTokensDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
    }

    func toDomain() throws -> AuthTokens {
        guard !accessToken.isEmpty, !refreshToken.isEmpty else {
            throw AuthError.invalidTokens
        }
        return AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }
}
```

- [ ] **Step 3: Update `TokenManaging.swift` — expand protocol**

Replace the full file with:

```swift
import Foundation
import Combine

protocol TokenManaging: TokenProviding, ObservableObject {
    var isLoggedIn: Bool { get }
    var isLoggedInPublisher: Published<Bool>.Publisher { get }
    func save(_ tokens: AuthTokens) throws
    func loadStoredTokens() -> AuthTokens?
    func clear()
    func refreshTokens() async throws
}
```

- [ ] **Step 4: Rewrite `TokenManager.swift` — mutex, expiry, proper error handling**

Replace the full file with:

```swift
import Foundation
import Combine

final class TokenManager: ObservableObject, TokenManaging {
    private let keychainService: KeychainServiceProtocol
    private let networkService: NetworkServiceProtocol
    private var currentTokens: AuthTokens?
    private var refreshTask: Task<AuthTokens, Error>?

    @Published var isLoggedIn: Bool = false

    var isLoggedInPublisher: Published<Bool>.Publisher { $isLoggedIn }

    var accessToken: String? {
        guard let tokens = currentTokens, !tokens.isExpired else {
            return nil
        }
        return tokens.accessToken
    }

    init(keychainService: KeychainServiceProtocol, networkService: NetworkServiceProtocol) {
        self.keychainService = keychainService
        self.networkService = networkService
    }

    func save(_ tokens: AuthTokens) throws {
        try keychainService.save(tokens.toDTO(), for: KeychainKey.accessToken)
        currentTokens = tokens
        isLoggedIn = !tokens.isExpired
    }

    func loadStoredTokens() -> AuthTokens? {
        do {
            guard let dto = try keychainService.load(AuthTokensDTO.self, for: KeychainKey.accessToken) else {
                return nil
            }
            let tokens = try dto.toDomain()
            currentTokens = tokens
            isLoggedIn = !tokens.isExpired
            return tokens
        } catch {
            return nil
        }
    }

    func clear() {
        do {
            try keychainService.delete(for: KeychainKey.accessToken)
        } catch {
            // Log error in production — keychain delete failed during logout
        }
        currentTokens = nil
        isLoggedIn = false
    }

    func refreshTokens() async throws {
        if let existingTask = refreshTask {
            _ = try await existingTask.value
            return
        }

        guard let refreshToken = currentTokens?.refreshToken else {
            throw AuthError.noRefreshToken
        }

        let task = Task<AuthTokens, Error> {
            let dto: AuthTokensDTO = try await networkService.request(
                endpoint: AuthEndpoint.refresh(refreshToken)
            )
            let newTokens = try dto.toDomain()
            try keychainService.save(dto, for: KeychainKey.accessToken)
            currentTokens = newTokens
            isLoggedIn = !newTokens.isExpired
            return newTokens
        }

        refreshTask = task

        do {
            _ = try await task.value
            refreshTask = nil
        } catch {
            refreshTask = nil
            throw error
        }
    }
}
```

- [ ] **Step 5: Update `AuthService.swift` — `toDomain()` now throws**

Update all calls from `dto.toDomain()` to `try dto.toDomain()`:

```swift
import Foundation

final class AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func login(email: String, password: String) async throws -> AuthTokens {
        let request = LoginRequest(email: email, password: password)
        let dto: AuthTokensDTO = try await networkService.request(
            endpoint: AuthEndpoint.login(request)
        )
        return try dto.toDomain()
    }

    func register(name: String, email: String, password: String) async throws -> AuthTokens {
        let request = RegisterRequest(name: name, email: email, password: password)
        let dto: AuthTokensDTO = try await networkService.request(
            endpoint: AuthEndpoint.register(request)
        )
        return try dto.toDomain()
    }

    func requestPasswordReset(email: String) async throws {
        let _: EmptyResponse = try await networkService.request(
            endpoint: AuthEndpoint.requestPasswordReset(email)
        )
    }

    func verifyOTP(email: String, code: String) async throws -> AuthTokens {
        let request = VerifyOTPRequest(email: email, code: code)
        let dto: AuthTokensDTO = try await networkService.request(
            endpoint: AuthEndpoint.verifyOTP(request)
        )
        return try dto.toDomain()
    }

    func refreshToken() async throws -> AuthTokens {
        throw AuthError.noRefreshToken
    }
}
```

- [ ] **Step 6: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: harden TokenManager with refresh mutex, expiry checks, DTO validation"
```

---

### Task 8: Add typed error handling and request guards to ViewModels

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Auth/Login/LoginViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/Register/RegisterViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/ForgotPassword/ForgotPasswordViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/OTPVerification/OTPVerificationViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Home/HomeList/HomeViewModel.swift`
- Modify: `SwiftUI-Boilerplate/Features/Home/ItemDetail/ItemDetailViewModel.swift`

- [ ] **Step 1: Rewrite `LoginViewModel.swift` with typed errors, request guard, task cancellation**

Replace the full file with:

```swift
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authRepository: AuthRepositoryProtocol
    private let router: any RouterProtocol
    private var currentTask: Task<Void, Never>?

    init(authRepository: AuthRepositoryProtocol, router: any RouterProtocol) {
        self.authRepository = authRepository
        self.router = router
    }

    deinit {
        currentTask?.cancel()
    }

    func login() {
        guard !isLoading else { return }
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }

        currentTask?.cancel()
        currentTask = Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                _ = try await authRepository.login(email: email, password: password)
            } catch is CancellationError {
                return
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch let error as AuthError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred."
            }
        }
    }

    func didTapForgotPassword() {
        router.push(AuthRoute.forgotPassword)
    }

    func didTapCreateAccount() {
        router.push(AuthRoute.register)
    }
}
```

- [ ] **Step 2: Rewrite `RegisterViewModel.swift`**

Replace the full file with:

```swift
import Foundation

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authRepository: AuthRepositoryProtocol
    private let router: any RouterProtocol
    private var currentTask: Task<Void, Never>?

    init(authRepository: AuthRepositoryProtocol, router: any RouterProtocol) {
        self.authRepository = authRepository
        self.router = router
    }

    deinit {
        currentTask?.cancel()
    }

    func register() {
        guard !isLoading else { return }
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        currentTask?.cancel()
        currentTask = Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                _ = try await authRepository.register(name: name, email: email, password: password)
                router.push(AuthRoute.otpVerification(email: email))
            } catch is CancellationError {
                return
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch let error as AuthError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred."
            }
        }
    }
}
```

- [ ] **Step 3: Rewrite `ForgotPasswordViewModel.swift`**

Replace the full file with:

```swift
import Foundation

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authRepository: AuthRepositoryProtocol
    private let router: any RouterProtocol
    private var currentTask: Task<Void, Never>?

    init(authRepository: AuthRepositoryProtocol, router: any RouterProtocol) {
        self.authRepository = authRepository
        self.router = router
    }

    deinit {
        currentTask?.cancel()
    }

    func requestReset() {
        guard !isLoading else { return }
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }

        currentTask?.cancel()
        currentTask = Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                try await authRepository.requestPasswordReset(email: email)
                router.push(AuthRoute.otpVerification(email: email))
            } catch is CancellationError {
                return
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred."
            }
        }
    }
}
```

- [ ] **Step 4: Rewrite `OTPVerificationViewModel.swift`**

Replace the full file with:

```swift
import Foundation

@MainActor
final class OTPVerificationViewModel: ObservableObject {
    @Published var code = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    let email: String
    private let authRepository: AuthRepositoryProtocol
    private var currentTask: Task<Void, Never>?

    init(email: String, authRepository: AuthRepositoryProtocol) {
        self.email = email
        self.authRepository = authRepository
    }

    deinit {
        currentTask?.cancel()
    }

    func verifyOTP() {
        guard !isLoading else { return }
        guard !code.isEmpty else {
            errorMessage = "Please enter the verification code"
            return
        }

        currentTask?.cancel()
        currentTask = Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                _ = try await authRepository.verifyOTP(email: email, code: code)
            } catch is CancellationError {
                return
            } catch let error as NetworkError {
                errorMessage = error.errorDescription
            } catch let error as AuthError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred."
            }
        }
    }
}
```

- [ ] **Step 5: Rewrite `HomeViewModel.swift`**

Replace the full file with:

```swift
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
```

- [ ] **Step 6: Rewrite `ItemDetailViewModel.swift`**

Replace the full file with:

```swift
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
```

- [ ] **Step 7: Update view files that call `async` methods now changed to sync**

The `login()`, `register()`, `requestReset()`, `verifyOTP()`, `loadItems()`, and `loadItem()` methods are no longer `async`. Update any `.task { await vm.login() }` calls in views to `.task { vm.login() }` (remove `await`).

Check and update these view files:
- `LoginView.swift` — if it uses `await viewModel.login()`, remove `await`
- `RegisterView.swift` — if it uses `await viewModel.register()`, remove `await`
- `ForgotPasswordView.swift` — if it uses `await viewModel.requestReset()`, remove `await`
- `OTPVerificationView.swift` — if it uses `await viewModel.verifyOTP()`, remove `await`
- `HomeView.swift` — if it uses `await viewModel.loadItems()`, remove `await`
- `ItemDetailView.swift` — if it uses `await viewModel.loadItem()`, remove `await`

For Button actions that were wrapped in `Task { await vm.login() }`, change to just `vm.login()`.

- [ ] **Step 8: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat: add typed error handling, request guards, task cancellation to ViewModels"
```

---

### Task 9: Add logout endpoint and deep link queuing

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Endpoints/AuthEndpoint.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Services/AuthServiceProtocol.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Services/AuthService.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Repositories/AuthRepository.swift`
- Modify: `SwiftUI-Boilerplate/App/AppCoordinator.swift`

- [ ] **Step 1: Add logout endpoint to `AuthEndpoint.swift`**

Add a new case:

```swift
enum AuthEndpoint: Endpoint {
    case login(LoginRequest)
    case register(RegisterRequest)
    case requestPasswordReset(String)
    case verifyOTP(VerifyOTPRequest)
    case refresh(String)
    case logout(String)

    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .register: return "/auth/register"
        case .requestPasswordReset: return "/auth/password-reset"
        case .verifyOTP: return "/auth/verify-otp"
        case .refresh: return "/auth/refresh"
        case .logout: return "/auth/logout"
        }
    }

    var method: HTTPMethod { .post }

    var body: Encodable? {
        switch self {
        case .login(let request): return request
        case .register(let request): return request
        case .requestPasswordReset(let email): return ["email": email]
        case .verifyOTP(let request): return request
        case .refresh(let token): return ["refresh_token": token]
        case .logout(let token): return ["refresh_token": token]
        }
    }
}
```

- [ ] **Step 2: Add `logout` to `AuthServiceProtocol.swift`**

```swift
import Foundation

protocol AuthServiceProtocol: AnyObject {
    func login(email: String, password: String) async throws -> AuthTokens
    func register(name: String, email: String, password: String) async throws -> AuthTokens
    func requestPasswordReset(email: String) async throws
    func verifyOTP(email: String, code: String) async throws -> AuthTokens
    func refreshToken() async throws -> AuthTokens
    func logout(refreshToken: String) async throws
}
```

- [ ] **Step 3: Implement `logout` in `AuthService.swift`**

Add to the class:

```swift
    func logout(refreshToken: String) async throws {
        let _: EmptyResponse = try await networkService.request(
            endpoint: AuthEndpoint.logout(refreshToken)
        )
    }
```

- [ ] **Step 4: Update `AuthRepository.swift` — server logout, accept tokenManager for token access**

Replace the `logout` method:

```swift
    func logout() async {
        if let tokens = tokenManager.loadStoredTokens() {
            try? await authService.logout(refreshToken: tokens.refreshToken)
        }
        tokenManager.clear()
    }
```

- [ ] **Step 5: Add pending deep link support to `AppCoordinator.swift`**

Replace the full file with:

```swift
import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    @Published var selectedTab: AppTab = .home

    private let tokenManager: any TokenManaging
    private let authRepository: AuthRepositoryProtocol
    private let deepLinkHandler: DeepLinkHandling
    private var cancellables = Set<AnyCancellable>()
    private var pendingDeepLink: DeepLink?

    let authRouter = Router()
    let routers: [AppTab: Router]

    init(tokenManager: any TokenManaging, authRepository: AuthRepositoryProtocol, deepLinkHandler: DeepLinkHandling) {
        self.tokenManager = tokenManager
        self.authRepository = authRepository
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
        isAuthenticated = tokenManager.loadStoredTokens() != nil
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

    func logout() async {
        await authRepository.logout()
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
```

- [ ] **Step 6: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: add server-side logout, pending deep link support"
```

---

### Task 10: Add unit test target with mocks

**Files:**
- Create: `SwiftUI-BoilerplateTests/Mocks/MockRouter.swift`
- Create: `SwiftUI-BoilerplateTests/Mocks/MockAuthRepository.swift`
- Create: `SwiftUI-BoilerplateTests/Mocks/MockHomeRepository.swift`
- Create: `SwiftUI-BoilerplateTests/Mocks/MockNetworkService.swift`
- Create: `SwiftUI-BoilerplateTests/Mocks/MockKeychainService.swift`
- Create: `SwiftUI-BoilerplateTests/Mocks/MockTokenManager.swift`

- [ ] **Step 1: Create the test target directory**

```bash
mkdir -p SwiftUI-BoilerplateTests/Mocks
```

- [ ] **Step 2: Create `MockRouter.swift`**

```swift
import SwiftUI
@testable import SwiftUI_Boilerplate

@MainActor
final class MockRouter: RouterProtocol {
    @Published var path = NavigationPath()
    @Published var sheetRoute: SheetRoute?
    @Published var fullScreenCoverRoute: FullScreenCoverRoute?

    var pushedRoutes: [any Hashable] = []
    var popCallCount = 0
    var popToRootCallCount = 0
    var presentedSheets: [SheetRoute] = []
    var presentedFullScreenCovers: [FullScreenCoverRoute] = []
    var dismissSheetCallCount = 0
    var dismissFullScreenCoverCallCount = 0

    func push<T: Hashable>(_ route: T) {
        pushedRoutes.append(route)
        path.append(route)
    }

    func pop() {
        popCallCount += 1
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        popToRootCallCount += 1
        path = NavigationPath()
    }

    func presentSheet(_ route: SheetRoute) {
        presentedSheets.append(route)
        sheetRoute = route
    }

    func presentFullScreenCover(_ route: FullScreenCoverRoute) {
        presentedFullScreenCovers.append(route)
        fullScreenCoverRoute = route
    }

    func dismissSheet() {
        dismissSheetCallCount += 1
        sheetRoute = nil
    }

    func dismissFullScreenCover() {
        dismissFullScreenCoverCallCount += 1
        fullScreenCoverRoute = nil
    }
}
```

- [ ] **Step 3: Create `MockAuthRepository.swift`**

```swift
import Foundation
@testable import SwiftUI_Boilerplate

final class MockAuthRepository: AuthRepositoryProtocol {
    var loginCallCount = 0
    var loginResult: Result<AuthTokens, Error> = .success(
        AuthTokens(accessToken: "token", refreshToken: "refresh", expiresAt: Date().addingTimeInterval(3600))
    )

    var registerCallCount = 0
    var registerResult: Result<AuthTokens, Error> = .success(
        AuthTokens(accessToken: "token", refreshToken: "refresh", expiresAt: Date().addingTimeInterval(3600))
    )

    var requestPasswordResetCallCount = 0
    var requestPasswordResetResult: Result<Void, Error> = .success(())

    var verifyOTPCallCount = 0
    var verifyOTPResult: Result<AuthTokens, Error> = .success(
        AuthTokens(accessToken: "token", refreshToken: "refresh", expiresAt: Date().addingTimeInterval(3600))
    )

    var logoutCallCount = 0

    func login(email: String, password: String) async throws -> AuthTokens {
        loginCallCount += 1
        return try loginResult.get()
    }

    func register(name: String, email: String, password: String) async throws -> AuthTokens {
        registerCallCount += 1
        return try registerResult.get()
    }

    func requestPasswordReset(email: String) async throws {
        requestPasswordResetCallCount += 1
        try requestPasswordResetResult.get()
    }

    func verifyOTP(email: String, code: String) async throws -> AuthTokens {
        verifyOTPCallCount += 1
        return try verifyOTPResult.get()
    }

    func logout() async {
        logoutCallCount += 1
    }
}
```

- [ ] **Step 4: Create `MockHomeRepository.swift`**

```swift
import Foundation
@testable import SwiftUI_Boilerplate

final class MockHomeRepository: HomeRepositoryProtocol {
    var fetchItemsCallCount = 0
    var fetchItemsResult: Result<[Item], Error> = .success([])

    var fetchItemCallCount = 0
    var fetchItemResult: Result<Item, Error> = .success(
        Item(id: "1", name: "Test", description: "Test item")
    )

    func fetchItems() async throws -> [Item] {
        fetchItemsCallCount += 1
        return try fetchItemsResult.get()
    }

    func fetchItem(id: String) async throws -> Item {
        fetchItemCallCount += 1
        return try fetchItemResult.get()
    }
}
```

- [ ] **Step 5: Create `MockNetworkService.swift`**

```swift
import Foundation
@testable import SwiftUI_Boilerplate

final class MockNetworkService: NetworkServiceProtocol {
    var requestCallCount = 0
    var requestHandler: ((any Endpoint) throws -> Any)?

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        requestCallCount += 1
        guard let handler = requestHandler else {
            fatalError("MockNetworkService.requestHandler not set")
        }
        guard let result = try handler(endpoint) as? T else {
            fatalError("MockNetworkService handler returned wrong type")
        }
        return result
    }
}
```

- [ ] **Step 6: Create `MockKeychainService.swift`**

```swift
import Foundation
@testable import SwiftUI_Boilerplate

final class MockKeychainService: KeychainServiceProtocol {
    var storage: [String: Data] = [:]
    var saveCallCount = 0
    var loadCallCount = 0
    var deleteCallCount = 0
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false

    func save(_ data: Data, for key: String) throws {
        saveCallCount += 1
        if shouldThrowOnSave {
            throw KeychainError.saveFailed(-1)
        }
        storage[key] = data
    }

    func load(for key: String) throws -> Data? {
        loadCallCount += 1
        if shouldThrowOnLoad {
            throw KeychainError.loadFailed(-1)
        }
        return storage[key]
    }

    func delete(for key: String) throws {
        deleteCallCount += 1
        storage.removeValue(forKey: key)
    }
}
```

- [ ] **Step 7: Create `MockTokenManager.swift`**

```swift
import Foundation
import Combine
@testable import SwiftUI_Boilerplate

final class MockTokenManager: TokenManaging {
    @Published var isLoggedIn: Bool = false

    var isLoggedInPublisher: Published<Bool>.Publisher { $isLoggedIn }

    var accessToken: String?
    var saveCallCount = 0
    var loadCallCount = 0
    var clearCallCount = 0
    var refreshCallCount = 0
    var shouldThrowOnSave = false
    var shouldThrowOnRefresh = false
    var storedTokens: AuthTokens?

    func save(_ tokens: AuthTokens) throws {
        saveCallCount += 1
        if shouldThrowOnSave {
            throw KeychainError.saveFailed(-1)
        }
        storedTokens = tokens
        accessToken = tokens.accessToken
        isLoggedIn = true
    }

    func loadStoredTokens() -> AuthTokens? {
        loadCallCount += 1
        if let tokens = storedTokens {
            isLoggedIn = true
            accessToken = tokens.accessToken
        }
        return storedTokens
    }

    func clear() {
        clearCallCount += 1
        storedTokens = nil
        accessToken = nil
        isLoggedIn = false
    }

    func refreshTokens() async throws {
        refreshCallCount += 1
        if shouldThrowOnRefresh {
            throw AuthError.noRefreshToken
        }
    }
}
```

- [ ] **Step 8: Add the test target to the Xcode project**

This must be done via Xcode or by manually editing the `.pbxproj`. The simplest approach is:

```bash
# Create a basic test file so the target has something to compile
cat > SwiftUI-BoilerplateTests/SwiftUI_BoilerplateTests.swift << 'EOF'
import XCTest
@testable import SwiftUI_Boilerplate

final class SwiftUI_BoilerplateTests: XCTestCase {
    func testProjectBuilds() {
        XCTAssertTrue(true)
    }
}
EOF
```

Then add the test target to the Xcode project. If using `xcodebuild`, you may need to open Xcode and add the target manually: File > New > Target > Unit Testing Bundle, name it `SwiftUI-BoilerplateTests`, and add all mock files + test files to it.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat: add unit test target with mock implementations"
```

---

### Task 11: Write unit tests for ViewModels

**Files:**
- Create: `SwiftUI-BoilerplateTests/Tests/LoginViewModelTests.swift`
- Create: `SwiftUI-BoilerplateTests/Tests/RegisterViewModelTests.swift`
- Create: `SwiftUI-BoilerplateTests/Tests/HomeViewModelTests.swift`
- Create: `SwiftUI-BoilerplateTests/Tests/TokenManagerTests.swift`

- [ ] **Step 1: Create `LoginViewModelTests.swift`**

```swift
import XCTest
@testable import SwiftUI_Boilerplate

@MainActor
final class LoginViewModelTests: XCTestCase {
    private var mockRepo: MockAuthRepository!
    private var mockRouter: MockRouter!
    private var sut: LoginViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockAuthRepository()
        mockRouter = MockRouter()
        sut = LoginViewModel(authRepository: mockRepo, router: mockRouter)
    }

    func testLoginEmptyFieldsShowsError() {
        sut.email = ""
        sut.password = ""
        sut.login()
        XCTAssertEqual(sut.errorMessage, "Please enter email and password")
        XCTAssertEqual(mockRepo.loginCallCount, 0)
    }

    func testLoginSuccessClearsError() async throws {
        sut.email = "test@test.com"
        sut.password = "password123"
        sut.login()

        // Wait for the internal Task to complete
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockRepo.loginCallCount, 1)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoginFailureShowsError() async throws {
        mockRepo.loginResult = .failure(NetworkError.noConnection)
        sut.email = "test@test.com"
        sut.password = "password123"
        sut.login()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockRepo.loginCallCount, 1)
        XCTAssertEqual(sut.errorMessage, "No internet connection")
        XCTAssertFalse(sut.isLoading)
    }

    func testDuplicateRequestGuard() async throws {
        sut.email = "test@test.com"
        sut.password = "password123"
        sut.isLoading = true
        sut.login()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockRepo.loginCallCount, 0)
    }

    func testDidTapForgotPasswordPushesRoute() {
        sut.didTapForgotPassword()
        XCTAssertEqual(mockRouter.pushedRoutes.count, 1)
    }

    func testDidTapCreateAccountPushesRoute() {
        sut.didTapCreateAccount()
        XCTAssertEqual(mockRouter.pushedRoutes.count, 1)
    }
}
```

- [ ] **Step 2: Create `RegisterViewModelTests.swift`**

```swift
import XCTest
@testable import SwiftUI_Boilerplate

@MainActor
final class RegisterViewModelTests: XCTestCase {
    private var mockRepo: MockAuthRepository!
    private var mockRouter: MockRouter!
    private var sut: RegisterViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockAuthRepository()
        mockRouter = MockRouter()
        sut = RegisterViewModel(authRepository: mockRepo, router: mockRouter)
    }

    func testRegisterEmptyFieldsShowsError() {
        sut.register()
        XCTAssertEqual(sut.errorMessage, "Please fill in all fields")
    }

    func testRegisterPasswordMismatchShowsError() {
        sut.name = "Test"
        sut.email = "test@test.com"
        sut.password = "password"
        sut.confirmPassword = "different"
        sut.register()
        XCTAssertEqual(sut.errorMessage, "Passwords do not match")
    }

    func testRegisterSuccessNavigatesToOTP() async throws {
        sut.name = "Test"
        sut.email = "test@test.com"
        sut.password = "password"
        sut.confirmPassword = "password"
        sut.register()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockRepo.registerCallCount, 1)
        XCTAssertEqual(mockRouter.pushedRoutes.count, 1)
        XCTAssertNil(sut.errorMessage)
    }

    func testRegisterFailureShowsError() async throws {
        mockRepo.registerResult = .failure(NetworkError.serverError(statusCode: 500, data: Data()))
        sut.name = "Test"
        sut.email = "test@test.com"
        sut.password = "password"
        sut.confirmPassword = "password"
        sut.register()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.errorMessage, "Server error (500)")
    }
}
```

- [ ] **Step 3: Create `HomeViewModelTests.swift`**

```swift
import XCTest
@testable import SwiftUI_Boilerplate

@MainActor
final class HomeViewModelTests: XCTestCase {
    private var mockRepo: MockHomeRepository!
    private var mockRouter: MockRouter!
    private var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockHomeRepository()
        mockRouter = MockRouter()
        sut = HomeViewModel(repository: mockRepo, router: mockRouter)
    }

    func testLoadItemsSuccess() async throws {
        let items = [
            Item(id: "1", name: "Item 1", description: "Desc 1"),
            Item(id: "2", name: "Item 2", description: "Desc 2")
        ]
        mockRepo.fetchItemsResult = .success(items)
        sut.loadItems()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(sut.items.count, 2)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadItemsFailure() async throws {
        mockRepo.fetchItemsResult = .failure(NetworkError.noConnection)
        sut.loadItems()

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(sut.items.isEmpty)
        XCTAssertEqual(sut.errorMessage, "No internet connection")
    }

    func testDidSelectItemPushesRoute() {
        let item = Item(id: "1", name: "Test", description: "Test")
        sut.didSelectItem(item)
        XCTAssertEqual(mockRouter.pushedRoutes.count, 1)
    }

    func testDidTapCreateItemPresentsSheet() {
        sut.didTapCreateItem()
        XCTAssertEqual(mockRouter.presentedSheets.count, 1)
    }
}
```

- [ ] **Step 4: Create `TokenManagerTests.swift`**

```swift
import XCTest
@testable import SwiftUI_Boilerplate

final class TokenManagerTests: XCTestCase {
    private var mockKeychain: MockKeychainService!
    private var mockNetwork: MockNetworkService!
    private var sut: TokenManager!

    override func setUp() {
        super.setUp()
        mockKeychain = MockKeychainService()
        mockNetwork = MockNetworkService()
        sut = TokenManager(keychainService: mockKeychain, networkService: mockNetwork)
    }

    func testSaveTokensUpdatesState() throws {
        let tokens = AuthTokens(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )
        try sut.save(tokens)
        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertEqual(sut.accessToken, "access")
        XCTAssertEqual(mockKeychain.saveCallCount, 1)
    }

    func testLoadStoredTokensSuccess() throws {
        let dto = AuthTokensDTO(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )
        let data = try JSONEncoder().encode(dto)
        mockKeychain.storage[KeychainKey.accessToken] = data

        let tokens = sut.loadStoredTokens()
        XCTAssertNotNil(tokens)
        XCTAssertTrue(sut.isLoggedIn)
    }

    func testLoadStoredTokensReturnsNilWhenEmpty() {
        let tokens = sut.loadStoredTokens()
        XCTAssertNil(tokens)
        XCTAssertFalse(sut.isLoggedIn)
    }

    func testClearRemovesTokens() throws {
        let tokens = AuthTokens(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )
        try sut.save(tokens)
        sut.clear()
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertNil(sut.accessToken)
    }

    func testExpiredTokenReturnsNilAccessToken() throws {
        let tokens = AuthTokens(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(-100)
        )
        try sut.save(tokens)
        XCTAssertNil(sut.accessToken)
    }

    func testRefreshMutexPreventsMultipleCalls() async throws {
        var callCount = 0
        mockNetwork.requestHandler = { _ in
            callCount += 1
            try await Task.sleep(nanoseconds: 50_000_000)
            return AuthTokensDTO(
                accessToken: "new",
                refreshToken: "new_refresh",
                expiresAt: Date().addingTimeInterval(3600)
            )
        }

        let tokens = AuthTokens(
            accessToken: "old",
            refreshToken: "old_refresh",
            expiresAt: Date().addingTimeInterval(-100)
        )
        try sut.save(tokens)

        async let refresh1: Void = sut.refreshTokens()
        async let refresh2: Void = sut.refreshTokens()

        try await refresh1
        try await refresh2

        // Should only have called network once due to mutex
        XCTAssertEqual(callCount, 1)
    }
}
```

- [ ] **Step 5: Run the tests**

Run: `xcodebuild test -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E '(Test Case|Tests? (Passed|Failed)|BUILD)'`
Expected: All tests pass

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "test: add unit tests for LoginVM, RegisterVM, HomeVM, TokenManager"
```

---

### Task 12: Add DTO CodingKeys for ItemDTO

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Home/Shared/DTOs/ItemDTO.swift`

- [ ] **Step 1: Update `ItemDTO.swift` with CodingKeys**

Replace the full file with:

```swift
import Foundation

struct ItemDTO: Codable {
    let id: String
    let name: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
    }

    func toDomain() -> Item {
        Item(id: id, name: name, description: description)
    }
}
```

- [ ] **Step 2: Verify the project builds**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor: add explicit CodingKeys to ItemDTO"
```

---

### Task 13: Final build and test verification

- [ ] **Step 1: Full build**

Run: `xcodebuild -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

- [ ] **Step 2: Run all tests**

Run: `xcodebuild test -scheme SwiftUI-Boilerplate -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E '(Test Case|Tests? (Passed|Failed)|BUILD)'`
Expected: All tests pass, BUILD SUCCEEDED

- [ ] **Step 3: Verify no force-unwraps remain in source code**

Run: `grep -rn '!' SwiftUI-Boilerplate/ --include="*.swift" | grep -v '//' | grep -v 'guard' | grep -v 'IBOutlet' | grep -v 'test' | grep -v 'Mock'`
Review output — any remaining `!` should be intentional (e.g., `URL(string: "https://api.example.com")!` in Endpoint default).
