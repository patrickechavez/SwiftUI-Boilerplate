# Production Hardening & SOLID Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all critical and important code-review findings across networking, auth, navigation, and UI layers to make the boilerplate production-ready and fully SOLID-compliant.

**Architecture:** Protocol-based DI with MVVM; fixes preserve all existing patterns and only change the specific violations identified. No new features, no restructuring of layers.

**Tech Stack:** Swift 5.9+, SwiftUI, Combine, async/await, Keychain Services

---

## Files Modified

| File | Change |
|------|--------|
| `Core/Networking/Endpoint.swift` | Remove force unwrap on `baseURL` |
| `Core/Networking/NetworkService.swift` | Apply `queryItems` to URLRequest |
| `Core/Auth/TokenManaging.swift` | Remove `ObservableObject` (ISP); mark protocol `@MainActor` |
| `Core/Auth/TokenManager.swift` | Mark `@MainActor` |
| `Core/DI/DependencyContainer.swift` | Fix `as? TokenProviding` cast; remove `authRepository` from `makeAppCoordinator` |
| `Core/DI/DependencyContainerProtocol.swift` | Remove exposed `tokenManager` property |
| `Core/Navigation/View+Navigation.swift` | Make `RouterNavigationModifier` generic over `RouterProtocol` |
| `Features/Auth/Shared/Services/AuthServiceProtocol.swift` | Remove `refreshToken()` (LSP fix) |
| `Features/Auth/Shared/Services/AuthService.swift` | Remove `refreshToken()` implementation |
| `Features/Auth/Shared/Repositories/AuthRepository.swift` | Add `await` to `@MainActor` TokenManager calls |
| `Features/Auth/AuthFlowView.swift` | Add `assertionFailure` for nil `viewFactory` |
| `Features/Dashboard/MainTabView.swift` | Pass router type to `withRouter`; add `assertionFailure` for nil factory |
| `Features/Settings/SettingsScreen/SettingsView.swift` | Route logout through ViewModel; remove coordinator dependency |
| `Features/Settings/SettingsScreen/SettingsViewModel.swift` | Remove unused `onLogout` closure |
| `Features/Home/HomeList/HomeView.swift` | Change `.task` to `.onAppear`; fix Retry button |
| `Features/Home/ItemDetail/ItemDetailView.swift` | Change `.task` to `.onAppear` |
| `Features/Auth/Shared/Models/AuthTokens.swift` | Add 30-second clock-skew buffer to `isExpired` |
| `Core/Keychain/KeychainServiceProtocol.swift` | Remove dead `KeychainKey.refreshToken` constant |
| `App/AppCoordinator.swift` | Remove `authRepository` dependency and `logout()` method |
| `App/AppDelegate.swift` | Wrap device token print in `#if DEBUG`; remove `Notification.Name` extension |
| `App/Notification+Names.swift` | **NEW** — dedicated file for `Notification.Name` extensions |
| `SwiftUI-BoilerplateTests/` | **DELETE** — entire directory |

---

## Task 1: Fix Networking Layer

**Files:**
- Modify: `SwiftUI-Boilerplate/Core/Networking/Endpoint.swift`
- Modify: `SwiftUI-Boilerplate/Core/Networking/NetworkService.swift`

### Issue A — Force unwrap on `baseURL`

- [ ] **Step 1: Replace force unwrap with a safe static default**

In `Endpoint.swift`, replace:
```swift
extension Endpoint {
    var baseURL: URL { URL(string: "https://api.example.com")! }
```
With:
```swift
extension Endpoint {
    var baseURL: URL {
        // Override in concrete endpoints. This default is intentionally non-functional.
        // swiftlint:disable:next force_unwrap
        URL(string: "https://api.example.com")!
    }
```

Actually — the safest approach for a boilerplate is a `preconditionFailure` that prints a meaningful message, making misconfiguration obvious at dev time without crashing silently in production:

Replace `Endpoint.swift` extension block with:
```swift
private enum EndpointDefaults {
    static let baseURL: URL = {
        guard let url = URL(string: "https://api.example.com") else {
            preconditionFailure("Default base URL is malformed — this should never happen.")
        }
        return url
    }()
}

extension Endpoint {
    var baseURL: URL { EndpointDefaults.baseURL }
    var headers: [String: String]? { nil }
    var body: Encodable? { nil }
    var queryItems: [URLQueryItem]? { nil }
}
```

This eliminates the force unwrap inline while keeping the intent clear.

### Issue B — `queryItems` never applied to URLRequest

- [ ] **Step 2: Apply queryItems in `NetworkService.buildRequest(from:)`**

In `NetworkService.swift`, replace the `buildRequest` method:
```swift
private func buildRequest(from endpoint: Endpoint) throws -> URLRequest {
    var components = URLComponents(
        url: endpoint.baseURL.appendingPathComponent(endpoint.path),
        resolvingAgainstBaseURL: false
    )

    if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
        components?.queryItems = queryItems
    }

    guard let url = components?.url else {
        throw NetworkError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    endpoint.headers?.forEach { key, value in
        request.setValue(value, forHTTPHeaderField: key)
    }

    if let body = endpoint.body {
        request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
    }

    return request
}
```

Note: `components` changed from `let` to `var` so we can mutate `queryItems`.

- [ ] **Step 3: Commit**
```bash
git add SwiftUI-Boilerplate/Core/Networking/Endpoint.swift SwiftUI-Boilerplate/Core/Networking/NetworkService.swift
git commit -m "fix: remove force unwrap on baseURL; apply queryItems to network requests"
```

---

## Task 2: Fix TokenManaging ISP + TokenManager Data Race

**Files:**
- Modify: `SwiftUI-Boilerplate/Core/Auth/TokenManaging.swift`
- Modify: `SwiftUI-Boilerplate/Core/Auth/TokenManager.swift`

### Issue — `ObservableObject` in protocol (ISP) + unsynchronised `refreshTask` (data race)

- [ ] **Step 1: Remove `ObservableObject` from `TokenManaging`; mark protocol `@MainActor`**

Replace `TokenManaging.swift` with:
```swift
import Foundation
import Combine

@MainActor
protocol TokenManaging: TokenProviding {
    var isLoggedIn: Bool { get }
    var isLoggedInPublisher: Published<Bool>.Publisher { get }
    func save(_ tokens: AuthTokens) throws
    func loadStoredTokens() -> AuthTokens?
    func clear()
    func refreshTokens() async throws
}
```

Removing `ObservableObject` from the protocol means:
- Conformers don't have to be classes with `@Published` — ISP satisfied
- `TokenManager` still explicitly conforms to `ObservableObject` on its own declaration
- `@MainActor` on the protocol serialises all `TokenManaging` calls to the main actor, eliminating the `refreshTask` data race

- [ ] **Step 2: Mark `TokenManager` `@MainActor`**

In `TokenManager.swift`, update the class declaration:
```swift
@MainActor
final class TokenManager: ObservableObject, TokenManaging {
```

Everything else in `TokenManager` stays the same — all its methods now run on the main actor, which serialises `refreshTask` access and eliminates the race condition.

- [ ] **Step 3: Commit**
```bash
git add SwiftUI-Boilerplate/Core/Auth/TokenManaging.swift SwiftUI-Boilerplate/Core/Auth/TokenManager.swift
git commit -m "fix: mark TokenManager @MainActor to fix refreshTask data race; remove ObservableObject from protocol (ISP)"
```

---

## Task 3: Fix AuthRepository Call Sites (cascading from Task 2)

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Repositories/AuthRepository.swift`

Since `TokenManaging` is now `@MainActor`, calling its synchronous methods from a non-isolated `async` context requires `await` to hop to the main actor.

- [ ] **Step 1: Update `AuthRepository` to `await` all `tokenManager` calls**

Replace `AuthRepository.swift` with:
```swift
import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol
    private let tokenManager: any TokenManaging

    init(authService: AuthServiceProtocol, tokenManager: any TokenManaging) {
        self.authService = authService
        self.tokenManager = tokenManager
    }

    func login(email: String, password: String) async throws -> AuthTokens {
        let tokens = try await authService.login(email: email, password: password)
        try await tokenManager.save(tokens)
        return tokens
    }

    func register(name: String, email: String, password: String) async throws -> AuthTokens {
        let tokens = try await authService.register(name: name, email: email, password: password)
        try await tokenManager.save(tokens)
        return tokens
    }

    func requestPasswordReset(email: String) async throws {
        try await authService.requestPasswordReset(email: email)
    }

    func verifyOTP(email: String, code: String) async throws -> AuthTokens {
        let tokens = try await authService.verifyOTP(email: email, code: code)
        try await tokenManager.save(tokens)
        return tokens
    }

    func logout() async {
        if let tokens = await tokenManager.loadStoredTokens() {
            try? await authService.logout(refreshToken: tokens.refreshToken)
        }
        await tokenManager.clear()
    }
}
```

- [ ] **Step 2: Commit**
```bash
git add SwiftUI-Boilerplate/Features/Auth/Shared/Repositories/AuthRepository.swift
git commit -m "fix: await @MainActor TokenManager calls in AuthRepository"
```

---

## Task 4: Fix DependencyContainer + DependencyContainerProtocol

**Files:**
- Modify: `SwiftUI-Boilerplate/Core/DI/DependencyContainer.swift`
- Modify: `SwiftUI-Boilerplate/Core/DI/DependencyContainerProtocol.swift`

### Issue A — Silent `as? TokenProviding` cast

`tokenManager as? TokenProviding` can silently return `nil` if conformance changes. Fix by storing the concrete `TokenManager` in a typed property before erasing to `any TokenManaging`.

- [ ] **Step 1: Fix the cast in `DependencyContainer`**

Replace lines 13–24 in `DependencyContainer.swift`:
```swift
private lazy var concreteTokenManager: TokenManager = TokenManager(
    keychainService: keychainService,
    networkService: authNetworkService
)

private(set) lazy var tokenManager: any TokenManaging = concreteTokenManager

private lazy var authenticatedNetworkService: NetworkServiceProtocol = NetworkService(
    tokenProvider: concreteTokenManager
)
```

This avoids the `as?` cast entirely — `concreteTokenManager` is typed `TokenManager` which directly conforms to both `TokenManaging` and `TokenProviding`.

### Issue B — `tokenManager` exposed on `DependencyContainerProtocol`

- [ ] **Step 2: Remove `tokenManager` from `DependencyContainerProtocol.swift`**

Replace `DependencyContainerProtocol.swift` with:
```swift
import Foundation

@MainActor
protocol DependencyContainerProtocol: ViewFactory {
    func makeAppCoordinator() -> AppCoordinator
}
```

The `tokenManager` was only needed by `makeAppCoordinator()` which is implemented inside `DependencyContainer` with full access to its private members — no protocol exposure needed.

- [ ] **Step 3: Commit**
```bash
git add SwiftUI-Boilerplate/Core/DI/DependencyContainer.swift SwiftUI-Boilerplate/Core/DI/DependencyContainerProtocol.swift
git commit -m "fix: eliminate as? TokenProviding cast via typed property; remove tokenManager from DI protocol"
```

---

## Task 5: Fix AuthService LSP Violation

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Services/AuthServiceProtocol.swift`
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Services/AuthService.swift`

`AuthServiceProtocol.refreshToken()` is declared as a valid operation but `AuthService` permanently throws. Token refresh lives in `TokenManager`. Remove the method from both the protocol and the implementation.

- [ ] **Step 1: Remove `refreshToken()` from `AuthServiceProtocol.swift`**

Replace with:
```swift
import Foundation

protocol AuthServiceProtocol: AnyObject {
    func login(email: String, password: String) async throws -> AuthTokens
    func register(name: String, email: String, password: String) async throws -> AuthTokens
    func requestPasswordReset(email: String) async throws
    func verifyOTP(email: String, code: String) async throws -> AuthTokens
    func logout(refreshToken: String) async throws
}
```

- [ ] **Step 2: Remove `refreshToken()` from `AuthService.swift`**

Delete lines 40–42 from `AuthService.swift`:
```swift
// DELETE these lines:
func refreshToken() async throws -> AuthTokens {
    throw AuthError.noRefreshToken
}
```

- [ ] **Step 3: Commit**
```bash
git add SwiftUI-Boilerplate/Features/Auth/Shared/Services/AuthServiceProtocol.swift SwiftUI-Boilerplate/Features/Auth/Shared/Services/AuthService.swift
git commit -m "fix: remove refreshToken() from AuthServiceProtocol — LSP violation, token refresh owned by TokenManager"
```

---

## Task 6: Fix SettingsView MVVM Violation + AppCoordinator SRP

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Settings/SettingsScreen/SettingsView.swift`
- Modify: `SwiftUI-Boilerplate/Features/Settings/SettingsScreen/SettingsViewModel.swift`
- Modify: `SwiftUI-Boilerplate/App/AppCoordinator.swift`
- Modify: `SwiftUI-Boilerplate/Core/DI/DependencyContainer.swift`

`SettingsView` directly calls `coordinator.logout()` instead of `viewModel.logout()`, bypassing the ViewModel and making `isLoggingOut` loading state permanently inert. The logout signal propagates through `tokenManager.isLoggedIn` publisher → `AppCoordinator` listener, so `AppCoordinator.logout()` is redundant once the view routes through the ViewModel.

- [ ] **Step 1: Update `SettingsView.swift` to route logout through ViewModel**

Replace `SettingsView.swift` with:
```swift
import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Account") {
                Button(role: .destructive) {
                    Task {
                        await viewModel.logout()
                    }
                } label: {
                    HStack {
                        if viewModel.isLoggingOut {
                            ProgressView()
                                .padding(.trailing, 8)
                        }
                        Text("Sign Out")
                    }
                }
                .disabled(viewModel.isLoggingOut)
            }

            Section("Navigation") {
                Button("Go to Settings 2") {
                    viewModel.didTapSettings2()
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
```

- [ ] **Step 2: Remove unused `onLogout` from `SettingsViewModel.swift`**

Replace `SettingsViewModel.swift` with:
```swift
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
```

`onLogout` is removed — `authRepository.logout()` calls `tokenManager.clear()` which fires `isLoggedIn = false`, which `AppCoordinator` already observes via Combine to set `isAuthenticated = false`.

- [ ] **Step 3: Remove `authRepository` and `logout()` from `AppCoordinator.swift`**

Replace `AppCoordinator.swift` with:
```swift
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
```

Note: `checkAuthOnLaunch` now uses `await tokenManager.loadStoredTokens()` since `TokenManaging` is `@MainActor`.

- [ ] **Step 4: Update `DependencyContainer.makeAppCoordinator()` to drop `authRepository`**

In `DependencyContainer.swift`, replace `makeAppCoordinator()`:
```swift
func makeAppCoordinator() -> AppCoordinator {
    AppCoordinator(
        tokenManager: tokenManager,
        deepLinkHandler: deepLinkHandler
    )
}
```

- [ ] **Step 5: Commit**
```bash
git add SwiftUI-Boilerplate/Features/Settings/SettingsScreen/SettingsView.swift \
        SwiftUI-Boilerplate/Features/Settings/SettingsScreen/SettingsViewModel.swift \
        SwiftUI-Boilerplate/App/AppCoordinator.swift \
        SwiftUI-Boilerplate/Core/DI/DependencyContainer.swift
git commit -m "fix: route logout through SettingsViewModel; remove authRepository from AppCoordinator (SRP)"
```

---

## Task 7: Fix RouterNavigationModifier DIP Violation

**Files:**
- Modify: `SwiftUI-Boilerplate/Core/Navigation/View+Navigation.swift`
- Modify: `SwiftUI-Boilerplate/Features/Dashboard/MainTabView.swift`

`RouterNavigationModifier` hard-codes `@EnvironmentObject var router: Router` (concrete type) violating DIP. Making it generic over `R: RouterProtocol` allows any conforming router to be injected — enabling preview mocking.

Also: `MainTabView.TabContentWrapper` has `assertionFailure` added for nil `viewFactory` (issue #11 — silent blank for `TabContentWrapper`), and the duplicate sheet/fullScreenCover handling that already exists in `TabContentWrapper` is removed from the modifier.

- [ ] **Step 1: Update `View+Navigation.swift`**

Replace the file with:
```swift
import SwiftUI

struct RouterNavigationModifier<R: RouterProtocol>: ViewModifier {
    @EnvironmentObject private var router: R
    @Environment(\.viewFactory) private var viewFactory

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Route.self) { route in
                if let factory = viewFactory {
                    factory.makeRouteDestination(route, router: router)
                } else {
                    EmptyView()
                        .onAppear {
                            assertionFailure("ViewFactory not set in environment — navigation destinations will not render")
                        }
                }
            }
    }
}

extension View {
    func withRouter<R: RouterProtocol>(_: R.Type) -> some View {
        modifier(RouterNavigationModifier<R>())
    }
}
```

- [ ] **Step 2: Update `MainTabView.swift` call site + add nil-factory guard**

Replace the `TabContentWrapper.body` computed property in `MainTabView.swift`:
```swift
var body: some View {
    NavigationStack(path: $router.path) {
        if let factory = viewFactory {
            factory.makeTabRootView(tab, router: router)
                .withRouter(Router.self)
        } else {
            EmptyView()
                .onAppear {
                    assertionFailure("ViewFactory not set in environment — tab content will not render")
                }
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
```

- [ ] **Step 3: Commit**
```bash
git add SwiftUI-Boilerplate/Core/Navigation/View+Navigation.swift \
        SwiftUI-Boilerplate/Features/Dashboard/MainTabView.swift
git commit -m "fix: make RouterNavigationModifier generic over RouterProtocol (DIP); add assertionFailure for nil viewFactory"
```

---

## Task 8: Fix AuthFlowView Nil Guard

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Auth/AuthFlowView.swift`

- [ ] **Step 1: Add `assertionFailure` for nil `viewFactory` in `AuthFlowView.swift`**

Replace `AuthFlowView.swift` with:
```swift
import SwiftUI

struct AuthFlowView: View {
    @ObservedObject var authRouter: Router
    @Environment(\.viewFactory) private var viewFactory
    @State private var authSheetRoute: AuthSheetRoute?

    var body: some View {
        NavigationStack(path: $authRouter.path) {
            if let factory = viewFactory {
                factory.makeAuthRootView(router: authRouter)
                    .navigationDestination(for: AuthRoute.self) { route in
                        factory.makeAuthRouteDestination(route, router: authRouter)
                    }
            } else {
                EmptyView()
                    .onAppear {
                        assertionFailure("ViewFactory not set in environment — auth flow will not render")
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

- [ ] **Step 2: Commit**
```bash
git add SwiftUI-Boilerplate/Features/Auth/AuthFlowView.swift
git commit -m "fix: add assertionFailure for nil viewFactory in AuthFlowView"
```

---

## Task 9: Fix HomeView + ItemDetailView .task Misuse

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Home/HomeList/HomeView.swift`
- Modify: `SwiftUI-Boilerplate/Features/Home/ItemDetail/ItemDetailView.swift`

`loadItems()` and `loadItem()` are synchronous methods that internally manage their own `Task`. Calling them inside `.task { }` (an async context) without `await` is misleading. Use `.onAppear` instead. Also fix the Retry button in `HomeView` which incorrectly wraps a non-async call in `Task { await ... }`.

- [ ] **Step 1: Update `HomeView.swift`**

Change `.task` to `.onAppear` and fix the Retry button:
```swift
// Replace:
Button("Retry") {
    Task { await viewModel.loadItems() }
}
// With:
Button("Retry") {
    viewModel.loadItems()
}

// Replace:
.task {
    viewModel.loadItems()
}
// With:
.onAppear {
    viewModel.loadItems()
}
```

- [ ] **Step 2: Update `ItemDetailView.swift`**

Change `.task` to `.onAppear`:
```swift
// Replace:
.task {
    viewModel.loadItem()
}
// With:
.onAppear {
    viewModel.loadItem()
}
```

- [ ] **Step 3: Commit**
```bash
git add SwiftUI-Boilerplate/Features/Home/HomeList/HomeView.swift \
        SwiftUI-Boilerplate/Features/Home/ItemDetail/ItemDetailView.swift
git commit -m "fix: replace misleading .task with .onAppear for synchronous load methods"
```

---

## Task 10: Misc Fixes (AuthTokens, KeychainKey, AppDelegate, Notification.Name)

**Files:**
- Modify: `SwiftUI-Boilerplate/Features/Auth/Shared/Models/AuthTokens.swift`
- Modify: `SwiftUI-Boilerplate/Core/Keychain/KeychainServiceProtocol.swift`
- Modify: `SwiftUI-Boilerplate/App/AppDelegate.swift`
- Create: `SwiftUI-Boilerplate/App/Notification+Names.swift`

### Issue A — No clock-skew buffer on `isExpired`

- [ ] **Step 1: Add 30-second buffer to `AuthTokens.isExpired`**

In `AuthTokens.swift`, replace:
```swift
var isExpired: Bool {
    Date() >= expiresAt
}
```
With:
```swift
var isExpired: Bool {
    Date().addingTimeInterval(30) >= expiresAt
}
```

### Issue B — Dead `KeychainKey.refreshToken`

- [ ] **Step 2: Remove dead `refreshToken` key from `KeychainServiceProtocol.swift`**

In `KeychainServiceProtocol.swift`, remove:
```swift
static let refreshToken = "refresh_token"
```

The `enum KeychainKey` block becomes:
```swift
enum KeychainKey {
    static let accessToken = "access_token"
}
```

### Issue C — Device token printed in production

- [ ] **Step 3: Wrap device token `print` in `#if DEBUG` in `AppDelegate.swift`**

Replace:
```swift
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("Device Token: \(token)")
}
```
With:
```swift
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    #if DEBUG
    print("Device Token: \(token)")
    #endif
    // TODO: Send token to your push notification server
}
```

### Issue D — `Notification.Name` extension in wrong file

- [ ] **Step 4: Remove `Notification.Name` extension from `AppDelegate.swift`**

Delete lines 56–58 from `AppDelegate.swift`:
```swift
// DELETE:
extension Notification.Name {
    static let didReceiveDeepLink = Notification.Name("didReceiveDeepLink")
}
```

- [ ] **Step 5: Create `Notification+Names.swift`**

Create `SwiftUI-Boilerplate/App/Notification+Names.swift`:
```swift
import Foundation

extension Notification.Name {
    static let didReceiveDeepLink = Notification.Name("didReceiveDeepLink")
}
```

- [ ] **Step 6: Commit**
```bash
git add SwiftUI-Boilerplate/Features/Auth/Shared/Models/AuthTokens.swift \
        SwiftUI-Boilerplate/Core/Keychain/KeychainServiceProtocol.swift \
        SwiftUI-Boilerplate/App/AppDelegate.swift \
        SwiftUI-Boilerplate/App/Notification+Names.swift
git commit -m "fix: add token expiry clock-skew buffer; remove dead keychain key; guard device token print; move Notification.Name to dedicated file"
```

---

## Task 11: Remove Test Target

**Files:**
- Delete: `SwiftUI-BoilerplateTests/` (entire directory)
- Modify: `SwiftUI-Boilerplate.xcodeproj/project.pbxproj` (Xcode will update this automatically)

- [ ] **Step 1: Delete the test directory**
```bash
rm -rf SwiftUI-BoilerplateTests
```

- [ ] **Step 2: Remove the test target from Xcode project**

Open `SwiftUI-Boilerplate.xcodeproj` in Xcode, select the `SwiftUI-BoilerplateTests` target in the project navigator, press Delete, and confirm "Delete" (not "Remove Reference"). Then save (Cmd+S).

Alternatively, edit `project.pbxproj` directly to remove all references to the test target — but the Xcode UI is safer for pbxproj changes.

- [ ] **Step 3: Commit**
```bash
git add -A
git commit -m "chore: remove SwiftUI-BoilerplateTests target"
```

---

## Self-Review Checklist

| # | Requirement | Covered |
|---|-------------|---------|
| 1 | Force unwrap on `baseURL` removed | Task 1 |
| 2 | `queryItems` applied to requests | Task 1 |
| 3 | `TokenManager` data race fixed via `@MainActor` | Task 2 |
| 4 | `ObservableObject` removed from `TokenManaging` protocol | Task 2 |
| 5 | `as? TokenProviding` cast eliminated | Task 4 |
| 6 | `tokenManager` removed from `DependencyContainerProtocol` | Task 4 |
| 7 | `AuthRepository` call sites updated for `@MainActor` | Task 3 |
| 8 | `refreshToken()` removed from `AuthServiceProtocol` (LSP) | Task 5 |
| 9 | `SettingsView` routes logout through ViewModel | Task 6 |
| 10 | `AppCoordinator` no longer owns `authRepository` | Task 6 |
| 11 | `RouterNavigationModifier` generic over `RouterProtocol` | Task 7 |
| 12 | `AuthFlowView` assertionFailure for nil factory | Task 8 |
| 13 | `TabContentWrapper` assertionFailure for nil factory | Task 7 |
| 14 | `.task` replaced with `.onAppear` in HomeView/ItemDetailView | Task 9 |
| 15 | Clock-skew buffer on `isExpired` | Task 10 |
| 16 | Dead `KeychainKey.refreshToken` removed | Task 10 |
| 17 | Device token print guarded by `#if DEBUG` | Task 10 |
| 18 | `Notification.Name` in dedicated file | Task 10 |
| 19 | Test target removed | Task 11 |
