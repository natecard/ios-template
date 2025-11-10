import Foundation

struct PreviewDependencies {
    // Default: zero-dependency-style preview wiring using URLSessionNetworkClient.
    // This keeps previews working even if Swinject/Alamofire are not linked.

    static let networkConfiguration: NetworkConfiguration = {
        // For previews, use a dummy/local URL; adjust as needed.
        let url = URL(string: "https://example.com")!
        return NetworkConfiguration(baseURLs: [.default: url])
    }()

    static let networkClient: NetworkClientProtocol = URLSessionNetworkClient(
        configuration: networkConfiguration
    )
    @MainActor
    static let purchaseManager: PurchaseManager = {
        PurchaseManager(networkClient: networkClient)
    }()

    // Optional: Swinject-based preview container (if you enable Swinject/Alamofire).
    // Uncomment this block and update usages if you prefer the AppContainer preview path.
    //
    // static let container = AppContainer.buildPreview()
    //
    // static var purchaseManagerFromContainer: PurchaseManager {
    //     guard let manager = container.resolve(PurchaseManager.self) else {
    //         fatalError("PurchaseManager not registered in preview container")
    //     }
    //     return manager
    // }
}
