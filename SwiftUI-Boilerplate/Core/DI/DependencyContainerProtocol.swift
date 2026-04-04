import Foundation

@MainActor
protocol DependencyContainerProtocol: ViewFactory {
    func makeAppCoordinator() -> AppCoordinator
}
