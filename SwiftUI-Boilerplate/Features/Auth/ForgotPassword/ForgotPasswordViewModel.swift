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
