import Foundation
import Swinject

struct TemplateFeatureAssembly: ServiceAssembly {
    func assemble(container: Container) {
        container.register(ItemsListViewModel.self) { resolver in
            guard
                let repository = resolver.resolve(ItemRepository.self),
                let dataManager = resolver.resolve(ItemDataManager.self)
            else {
                fatalError("Dependencies not registered for ItemsListViewModel")
            }
            return ItemsListViewModel(repository: repository, dataManager: dataManager)
        }
        .inObjectScope(.transient)

        container.register(SearchViewModel.self) { resolver in
            guard
                let repository = resolver.resolve(ItemRepository.self),
                let dataManager = resolver.resolve(ItemDataManager.self)
            else {
                fatalError("Dependencies not registered for SearchViewModel")
            }
            return SearchViewModel(repository: repository, dataManager: dataManager)
        }
        .inObjectScope(.transient)

        container.register(SettingsViewModel.self) { resolver in
            guard
                let purchaseManager = resolver.resolve(PurchaseManager.self),
                let dataManager = resolver.resolve(ItemDataManager.self),
                let fileStorage = resolver.resolve(FileStorageProvider.self)
            else {
                fatalError("Dependencies not registered for SettingsViewModel")
            }
            return SettingsViewModel(
                purchaseManager: purchaseManager,
                dataManager: dataManager,
                fileStorage: fileStorage
            )
        }
        .inObjectScope(.transient)
    }
}
