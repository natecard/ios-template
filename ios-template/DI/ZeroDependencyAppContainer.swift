import Foundation

///
/// This variant is zero dependency and can be used as an alternative to `AppContainer`.
/// It wires dependencies manually in code for clarity and zero external deps.
/// 
struct ZeroDependencyAppContainer {
    // Core singletons / services
    let networkConfiguration: NetworkConfiguration
    let networkClient: NetworkClientProtocol

    let itemRepository: ItemRepository
    let jsonPersistenceService: JSONPersistenceService
    let purchaseManager: PurchaseManager
    let fileStorageProvider: FileStorageProvider
    let itemDataManager: ItemDataManager

    // Feature-level view models (factories instead of singletons)
    func makeItemsListViewModel() -> ItemsListViewModel {
        ItemsListViewModel(
            repository: itemRepository,
            dataManager: itemDataManager
        )
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            repository: itemRepository,
            dataManager: itemDataManager
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            purchaseManager: purchaseManager,
            dataManager: itemDataManager,
            fileStorage: fileStorageProvider
        )
    }
}

extension ZeroDependencyAppContainer {
    /// Build the zero-dependency container using `URLSessionNetworkClient`.
    static func build() -> ZeroDependencyAppContainer {
        // Read base URLs from Info.plist like the Swinject-based setup.
        var baseURLs: [NetworkBaseURL: URL] = [:]

        if let defaultURLString = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
           let defaultURL = URL(string: defaultURLString) {
            baseURLs[.default] = defaultURL
        }

        if let purchasesURLString = Bundle.main.object(forInfoDictionaryKey: "IAPValidationURL") as? String,
           let purchasesURL = URL(string: purchasesURLString) {
            baseURLs[.purchases] = purchasesURL
        }

        if let sandboxURLString = Bundle.main.object(forInfoDictionaryKey: "IAPValidationURLSandbox") as? String,
           let sandboxURL = URL(string: sandboxURLString) {
            baseURLs[.purchasesSandbox] = sandboxURL
        }

        let networkConfiguration = NetworkConfiguration(baseURLs: baseURLs)
        let networkClient: NetworkClientProtocol = URLSessionNetworkClient(configuration: networkConfiguration)

        let jsonPersistenceService = try! JSONPersistenceService()
        let fileStorageProvider = try! FileStorageProvider()

        let itemDataManager = ItemDataManager(persistenceService: jsonPersistenceService)
        let itemRepository = ItemRepository(networkClient: networkClient)
        let purchaseManager = PurchaseManager(networkClient: networkClient)

        return ZeroDependencyAppContainer(
            networkConfiguration: networkConfiguration,
            networkClient: networkClient,
            itemRepository: itemRepository,
            jsonPersistenceService: jsonPersistenceService,
            purchaseManager: purchaseManager,
            fileStorageProvider: fileStorageProvider,
            itemDataManager: itemDataManager
        )
    }
}

actor ZeroDependencyBootstrapActor {
    static let shared = ZeroDependencyBootstrapActor()

    func bootstrap() async throws -> ZeroDependencyAppContainer {
        // Currently synchronous; kept async so projects can extend this.
        return await ZeroDependencyAppContainer.build()
    }
}
