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
