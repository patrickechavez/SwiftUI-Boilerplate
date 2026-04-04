import SwiftUI

struct Home3View: View {
    @StateObject var viewModel: Home3ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Home Screen 3")
                .font(.title)

            Button("Pop to Root") {
                viewModel.didTapPopToRoot()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Home 3")
        .task { await viewModel.loadData() }
    }
}
