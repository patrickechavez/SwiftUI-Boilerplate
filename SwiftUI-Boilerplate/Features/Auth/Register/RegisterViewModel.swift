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
