import SwiftUI

struct Settings2View: View {
    @StateObject var viewModel: Settings2ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings Screen 2")
                .font(.title)

            Button("Go to Settings 3") {
                viewModel.didTapNext()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Settings 2")
        .task { await viewModel.loadData() }
    }
}
