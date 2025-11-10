import Foundation

struct PreviewDependencies {
    static let container = AppContainer.buildPreview()

    static var purchaseManager: PurchaseManager {
        guard let manager = container.resolve(PurchaseManager.self) else {
            fatalError("PurchaseManager not registered in preview container")
        }
        return manager
    }
}
