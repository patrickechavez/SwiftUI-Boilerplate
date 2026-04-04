import SwiftUI

struct Settings3View: View {
    @StateObject var viewModel: Settings3ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings Screen 3")
                .font(.title)

            Button("Pop to Root") {
                viewModel.didTapPopToRoot()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Settings 3")
        .task { await viewModel.loadData() }
    }
}
