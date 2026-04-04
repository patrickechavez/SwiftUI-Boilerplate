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
