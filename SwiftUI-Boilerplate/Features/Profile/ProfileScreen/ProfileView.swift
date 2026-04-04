import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile Screen")
                .font(.title)

            Button("Go to Profile 2") {
                viewModel.didTapNext()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Profile")
        .task { await viewModel.loadData() }
    }
}
