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
