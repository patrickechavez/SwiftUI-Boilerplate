import SwiftUI

struct Profile2View: View {
    @StateObject var viewModel: Profile2ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile Screen 2")
                .font(.title)

            Button("Go to Profile 3") {
                viewModel.didTapNext()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Profile 2")
        .task { await viewModel.loadData() }
    }
}
