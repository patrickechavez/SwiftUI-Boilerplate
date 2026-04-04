import SwiftUI

struct ItemDetailView: View {
    @StateObject var viewModel: ItemDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let item = viewModel.item {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(item.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(item.description)
                            .font(.body)
                            .foregroundColor(.secondary)

                        Divider()

                        HStack(spacing: 12) {
                            Button("Edit") {
                                viewModel.didTapEdit()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        viewModel.loadItem()
                    }
                }
            }
        }
        .navigationTitle("Item Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadItem()
        }
    }
}
