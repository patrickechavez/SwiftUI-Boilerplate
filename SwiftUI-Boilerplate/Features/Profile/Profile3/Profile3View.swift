import SwiftUI

struct Profile3View: View {
    @StateObject var viewModel: Profile3ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile Screen 3")
                .font(.title)

            Button("Pop to Root") {
                viewModel.didTapPopToRoot()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Profile 3")
        .task { await viewModel.loadData() }
    }
}
