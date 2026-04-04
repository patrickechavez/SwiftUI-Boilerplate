import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                if let router = coordinator.routers[tab] {
                    TabContentWrapper(
                        router: router,
                        tab: tab
                    )
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
                }
            }
        }
    }
}

private struct TabContentWrapper: View {
    @ObservedObject var router: Router
    @Environment(\.viewFactory) private var viewFactory
    let tab: AppTab

    var body: some View {
        NavigationStack(path: $router.path) {
            if let factory = viewFactory {
                factory.makeTabRootView(tab, router: router)
                    .withRouter(Router.self)
            } else {
                EmptyView()
                    .onAppear {
                        assertionFailure("ViewFactory not set in environment — tab content will not render")
                    }
            }
        }
        .sheet(item: $router.sheetRoute) { route in
            sheetContent(for: route)
        }
        .fullScreenCover(item: $router.fullScreenCoverRoute) { route in
            fullScreenContent(for: route)
        }
        .environmentObject(router)
    }

    @ViewBuilder
    private func sheetContent(for route: SheetRoute) -> some View {
        switch route {
        case .createItem:
            Text("Create Item")
        case .editItem(let id):
            Text("Edit Item: \(id)")
        }
    }

    @ViewBuilder
    private func fullScreenContent(for route: FullScreenCoverRoute) -> some View {
        switch route {
        case .imageViewer(let url):
            VStack {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                Button("Dismiss") {
                    router.dismissFullScreenCover()
                }
                .padding()
            }
        }
    }
}
