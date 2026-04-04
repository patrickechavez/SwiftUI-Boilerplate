import SwiftUI

struct Home2View: View {
    @StateObject var viewModel: Home2ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Home Screen 2")
                .font(.title)

            Button("Go to Home 3") {
                viewModel.didTapNext()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Home 2")
        .task { await viewModel.loadData() }
    }
}
