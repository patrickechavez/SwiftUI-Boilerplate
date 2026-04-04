import SwiftUI

struct OTPVerificationView: View {
    @StateObject var viewModel: OTPVerificationViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "number.square")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)

                Text("Verify Your Email")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Enter the code sent to \(viewModel.email)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            TextField("Verification Code", text: $viewModel.code)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title2)
                .padding(.horizontal)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                viewModel.verifyOTP()
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Verify")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
    }
}
