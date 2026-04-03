# SOLID & Production Hardening Design Spec

**Date:** 2026-04-03
**Goal:** Refactor SwiftUI-Boilerplate into a production-grade, fully testable app template following SOLID principles with protocol-based DI throughout.
**Approach:** Protocol-First Refactor (Approach 2) — harden existing architecture without rewriting or changing iOS version targets.

---

## Section 1: DI Container Refactor

### Problem
`DependencyContainer.shared` is a singleton. Tests cannot swap mock dependencies. View creation is coupled directly into the container.

### Design

- Extract `DependencyContainerProtocol` defining all factory methods:
  - `makeAuthService() -> AuthServiceProtocol`
  - `makeAuthRepository() -> AuthRepositoryProtocol`
  - `makeHomeRepository() -> HomeRepositoryProtocol`
  - `makeTokenManager() -> TokenManaging`
  - `makeKeychainService() -> KeychainServiceProtocol`
  - `makeNetworkService(tokenProvider:) -> NetworkServiceProtocol`
- `DependencyContainer` becomes a concrete conformance — no longer uses `static let shared`.
- App entry point creates the container and passes it to `AppCoordinator`.
- `ViewFactory` remains a separate protocol. `DependencyContainer` conforms to it.
- Tests create `MockDependencyContainer` conforming to the same protocol.

### Dependency Flow

```
SwiftUI_BoilerplateApp
  └── creates DependencyContainer (concrete)
        └── passed to AppCoordinator
              └── creates ViewModels via container protocol
```

### Files Affected
- `Core/DI/DependencyContainer.swift` — refactor to protocol conformance, remove singleton
- `Core/DI/DependencyContainerProtocol.swift` — new protocol file
- `App/SwiftUI_BoilerplateApp.swift` — create container at entry point
- `App/AppCoordinator.swift` — accept protocol instead of concrete

---

## Section 2: Router Protocol & ViewModel Decoupling

### Problem
ViewModels depend on concrete `Router` class. Navigation cannot be mocked in tests. Force-unwraps on `viewFactory!` can crash.

### Design

- Extract `RouterProtocol`:
  - `push(_ route: Route)`
  - `pop()`
  - `popToRoot()`
  - `presentSheet(_ route: Route)`
  - `presentFullScreenCover(_ route: Route)`
  - `dismissSheet()`
  - `dismissFullScreenCover()`
- `Router` conforms to `RouterProtocol`.
- All ViewModels depend on `RouterProtocol`, not `Router`.
- Remove force-unwraps in `View+Navigation.swift` — use `guard let` with empty view fallback.
- Remove force-unwraps in `MainTabView.swift` — use `guard let` with assertion in debug.

### Files Affected
- `Core/Navigation/RouterProtocol.swift` — new protocol file
- `Core/Navigation/Router.swift` — add protocol conformance
- `Core/Navigation/View+Navigation.swift` — safe unwrapping
- `Features/Auth/Login/LoginViewModel.swift` — depend on protocol
- `Features/Auth/Register/RegisterViewModel.swift` — depend on protocol
- `Features/Auth/OTPVerification/OTPVerificationViewModel.swift` — depend on protocol
- `Features/Auth/ForgotPassword/ForgotPasswordViewModel.swift` — depend on protocol
- `Features/Home/HomeList/HomeViewModel.swift` — depend on protocol
- `Features/Home/ItemDetail/ItemDetailViewModel.swift` — depend on protocol
- `Features/Home/Home2/Home2ViewModel.swift` — depend on protocol
- `Features/Home/Home3/Home3ViewModel.swift` — depend on protocol
- `Features/Profile/ProfileScreen/ProfileViewModel.swift` — depend on protocol
- `Features/Profile/Profile2/Profile2ViewModel.swift` — depend on protocol
- `Features/Profile/Profile3/Profile3ViewModel.swift` — depend on protocol
- `Features/Settings/SettingsScreen/SettingsViewModel.swift` — depend on protocol
- `Features/Settings/Settings2/Settings2ViewModel.swift` — depend on protocol
- `Features/Settings/Settings3/Settings3ViewModel.swift` — depend on protocol
- `Features/Dashboard/MainTabView.swift` — safe unwrapping

---

## Section 3: Token Management Hardening

### Problem
Race condition on concurrent refresh, no token expiry checking, silent errors, `isLoggedIn` can be inconsistent with actual token state.

### Design

- **Refresh mutex** — Use a shared `Task` reference so only one refresh runs at a time. Concurrent callers await the same in-flight task:

```swift
private var refreshTask: Task<AuthTokens, Error>?

func refreshTokens() async throws -> AuthTokens {
    if let existing = refreshTask {
        return try await existing.value
    }
    let task = Task {
        defer { refreshTask = nil }
        // perform refresh network call
        // save to keychain
        // update cache
        return newTokens
    }
    refreshTask = task
    return try await task.value
}
```

- **Token expiry** — Add `expiresAt: Date` to `AuthTokens`. Check before each request. Proactively refresh if expired instead of waiting for 401.
- **Replace silent `try?`** — All keychain operations use `do/catch` with proper error propagation or logging.
- **Single source of truth** — Keychain is authoritative. `currentTokens` is an in-memory cache validated against keychain on read.
- **`isLoggedIn` derived** — Computed property based on whether valid, non-expired tokens exist.

```swift
var isLoggedIn: Bool {
    guard let tokens = currentTokens else { return false }
    return !tokens.isExpired
}
```

- **Update `TokenManaging` protocol** to include the full public interface.

### Files Affected
- `Core/Auth/TokenManager.swift` — refresh mutex, expiry, derived state
- `Core/Auth/TokenManaging.swift` — expanded protocol
- `Features/Auth/Shared/Models/AuthTokens.swift` — add `expiresAt`, `isExpired`
- `Features/Auth/Shared/DTOs/AuthTokensDTO.swift` — add expiry field mapping
- `Core/Networking/NetworkService.swift` — proactive expiry check before request

---

## Section 4: Error Handling & Safety

### Problem
Force-unwraps that crash, `try?` swallowing errors, generic `error.localizedDescription` for all failures.

### Design

- **Remove all force-unwraps** — Replace with `guard let` or safe defaults:
  - `viewFactory!` in navigation modifiers → `guard let` with `EmptyView` fallback
  - `coordinator.routers[tab]!` → `guard let` with debug assertion

- **Replace all silent `try?`** — Proper `do/catch` with error logging or propagation.

- **Typed error handling in ViewModels:**

```swift
catch let error as NetworkError {
    switch error {
    case .unauthorized: errorMessage = "Session expired. Please log in again."
    case .serverError: errorMessage = "Something went wrong. Please try again."
    case .noConnection: errorMessage = "No internet connection."
    default: errorMessage = "An unexpected error occurred."
    }
} catch let error as AuthError {
    // auth-specific user-facing messages
} catch {
    errorMessage = "An unexpected error occurred."
}
```

- **Expand `NetworkError`** — Add cases:
  - `.noConnection`
  - `.serverError(statusCode: Int)`
  - `.clientError(statusCode: Int)`

- **Duplicate request guard in ViewModels:**

```swift
guard !isLoading else { return }
isLoading = true
defer { isLoading = false }
```

### Files Affected
- `Core/Networking/NetworkError.swift` — expanded cases
- `Core/Networking/NetworkService.swift` — map status codes to new error types
- `Core/Navigation/View+Navigation.swift` — remove force-unwraps
- `Features/Dashboard/MainTabView.swift` — remove force-unwraps
- All ViewModels — typed error handling, duplicate request guard

---

## Section 5: Keychain Security Hardening

### Problem
No access control attributes, non-atomic save (delete-then-add), silent failures, no data validation.

### Design

- **Access control** — All token storage uses `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.

- **Atomic save** — Use `SecItemUpdate` first, fall back to `SecItemAdd` if item doesn't exist:

```swift
func save(_ data: Data, for key: String) throws {
    let status = SecItemUpdate(matchQuery, updateAttributes)
    if status == errSecItemNotFound {
        let addStatus = SecItemAdd(fullQuery, nil)
        guard addStatus == errSecSuccess else {
            throw KeychainError.saveFailed(addStatus)
        }
    } else if status != errSecSuccess {
        throw KeychainError.saveFailed(status)
    }
}
```

- **Richer `KeychainError`:**

```swift
enum KeychainError: Error {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case dataConversionFailed
}
```

- **Validation on load** — Verify decoded tokens aren't empty strings before returning.

### Files Affected
- `Core/Keychain/KeychainService.swift` — atomic save, access control
- `Core/Keychain/KeychainError.swift` — richer error cases

---

## Section 6: Testability Architecture

### Problem
No test targets exist. Singleton container, concrete Router, and lack of mocks prevent unit testing.

### Design

- **Add `SwiftUI-BoilerplateTests` target** in Xcode project.

- **Mock files in test target:**

```
SwiftUI-BoilerplateTests/
  Mocks/
    MockNetworkService.swift
    MockAuthRepository.swift
    MockAuthService.swift
    MockKeychainService.swift
    MockTokenManager.swift
    MockRouter.swift
    MockDependencyContainer.swift
    MockHomeRepository.swift
```

- **Mock pattern** — Track calls and return configurable results:

```swift
final class MockAuthRepository: AuthRepositoryProtocol {
    var loginCallCount = 0
    var loginResult: Result<Void, Error> = .success(())

    func login(email: String, password: String) async throws {
        loginCallCount += 1
        try loginResult.get()
    }
}
```

- **Test coverage targets:**
  - All ViewModels — login, register, OTP, forgot password, home
  - AuthRepository — token storage, login/logout flow
  - TokenManager — refresh mutex, expiry, keychain interaction
  - NetworkService — request building, error mapping, 401 retry
  - KeychainService — save/load/delete, error cases

- **ViewModel test example:**

```swift
func testLoginSuccess() async {
    let mockRepo = MockAuthRepository()
    let mockRouter = MockRouter()
    let vm = LoginViewModel(authRepository: mockRepo, router: mockRouter)

    vm.email = "test@test.com"
    vm.password = "password"
    await vm.login()

    XCTAssertEqual(mockRepo.loginCallCount, 1)
    XCTAssertNil(vm.errorMessage)
}
```

---

## Section 7: Remaining Production Fixes

### Request Cancellation
Store `Task` reference in ViewModels, cancel on `deinit` or navigation away:

```swift
private var currentTask: Task<Void, Never>?

func login() {
    currentTask?.cancel()
    currentTask = Task {
        guard !Task.isCancelled else { return }
        // ... work
    }
}

deinit { currentTask?.cancel() }
```

### DTO CodingKeys
Add explicit `CodingKeys` for snake_case JSON mapping:

```swift
enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
}
```

### DTO Validation
Validate decoded data before domain mapping:

```swift
func toDomain() throws -> AuthTokens {
    guard !accessToken.isEmpty, !refreshToken.isEmpty else {
        throw AuthError.invalidTokens
    }
    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken)
}
```

### Deep Link Handling
Store pending deep link when unauthenticated, process after login completes:

```swift
private var pendingDeepLink: DeepLink?

func handleDeepLink(_ url: URL) {
    let deepLink = DeepLinkHandler.parse(url)
    if isAuthenticated {
        navigate(to: deepLink)
    } else {
        pendingDeepLink = deepLink
    }
}

// After login succeeds:
func onLoginSuccess() {
    if let pending = pendingDeepLink {
        navigate(to: pending)
        pendingDeepLink = nil
    }
}
```

### Logout Server Call
Add endpoint to invalidate refresh token server-side before clearing local state:

```swift
func logout() async {
    try? await authService.logout()  // best-effort server call
    tokenManager.clear()
}
```

### Files Affected
- All ViewModels — task cancellation, duplicate request guard
- `Features/Auth/Shared/DTOs/AuthTokensDTO.swift` — CodingKeys, validation
- `Features/Home/Shared/DTOs/ItemDTO.swift` — CodingKeys if needed
- `App/AppCoordinator.swift` — pending deep link support
- `Features/Auth/Shared/Endpoints/AuthEndpoint.swift` — logout endpoint
- `Features/Auth/Shared/Services/AuthService.swift` — logout method
- `Features/Auth/Shared/Repositories/AuthRepository.swift` — server logout call

---

## Summary of Changes

| Area | Key Change | Impact |
|------|-----------|--------|
| DI Container | Protocol-based, no singleton | All dependency creation |
| Router | Protocol-based, mockable | All ViewModels, navigation |
| Token Management | Refresh mutex, expiry checks, derived state | Auth flow, networking |
| Error Handling | Typed errors, no force-unwraps, no silent failures | All layers |
| Keychain | Security attributes, atomic save, richer errors | Token storage |
| Testing | Test target, mocks for all protocols, example tests | New test target |
| Production | Task cancellation, DTO validation, deep link queuing, server logout | Various features |
