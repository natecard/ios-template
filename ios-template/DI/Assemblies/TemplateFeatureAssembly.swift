//
//  TemplateFeatureAssembly.swift
//  ios-template
//
//
//

// // MARK: - Optional Template Feature Assembly
// //
// // This assembly wires feature view models using Swinject.
// // It is commented out by default to keep the template dependency-free.
// // To use it:
// // 1. Add Swinject to your project.
// // 2. Uncomment this file and integrate `TemplateFeatureAssembly` into your container bootstrap.

// import Foundation
// import Swinject

// struct TemplateFeatureAssembly: ServiceAssembly {
//     func assemble(container: Container) {
//         container.register(ItemsListViewModel.self) { resolver in
//             guard
//                 let repository = resolver.resolve(ItemRepository.self),
//                 let dataManager = resolver.resolve(ItemDataManager.self)
//             else {
//                 fatalError("Dependencies not registered for ItemsListViewModel")
//             }
//             return ItemsListViewModel(repository: repository, dataManager: dataManager)
//         }
//         .inObjectScope(.transient)

//         container.register(SearchViewModel.self) { resolver in
//             guard
//                 let repository = resolver.resolve(ItemRepository.self),
//                 let dataManager = resolver.resolve(ItemDataManager.self)
//             else {
//                 fatalError("Dependencies not registered for SearchViewModel")
//             }
//             return SearchViewModel(repository: repository, dataManager: dataManager)
//         }
//         .inObjectScope(.transient)

//         container.register(SettingsViewModel.self) { resolver in
//             guard
//                 let purchaseManager = resolver.resolve(PurchaseManager.self),
//                 let dataManager = resolver.resolve(ItemDataManager.self),
//                 let fileStorage = resolver.resolve(FileStorageProvider.self)
//             else {
//                 fatalError("Dependencies not registered for SettingsViewModel")
//             }
//             return SettingsViewModel(
//                 purchaseManager: purchaseManager,
//                 dataManager: dataManager,
//                 fileStorage: fileStorage
//             )
//         }
//         .inObjectScope(.transient)
//     }
// }
