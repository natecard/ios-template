//
//  DomainAssembly.swift
//  ios-template
//
//
//

// // MARK: - Optional Domain Assembly
// //
// // This assembly wires repositories and managers using Swinject.
// // It is commented out by default to keep the template dependency-free.
// // To use it:
// // 1. Add Swinject to your project.
// // 2. Uncomment this file and integrate `DomainAssembly` into your container bootstrap.

// //import Foundation
// //import Swinject

// //struct DomainAssembly: ServiceAssembly {
//     func assemble(container: Container) {
//         // Register core template domain types.
//         container.register(ItemRepository.self) { resolver in
//             guard let client = resolver.resolve(NetworkClientProtocol.self) else {
//                 fatalError("NetworkClientProtocol not registered")
//             }
//             return ItemRepository(networkClient: client)
//         }
//         .inObjectScope(.container)

//         container.register(JSONPersistenceService.self) { _ in
//             try! JSONPersistenceService()
//         }
//         .inObjectScope(.container)

//         container.register(PurchaseManager.self) { resolver in
//             guard let networkClient = resolver.resolve(NetworkClientProtocol.self) else {
//                 fatalError("NetworkClientProtocol not registered")
//             }
//             return PurchaseManager(networkClient: networkClient)
//         }
//         .inObjectScope(.container)

//         container.register(FileStorageProvider.self) { _ in
//             try! FileStorageProvider()
//         }
//         .inObjectScope(.container)

//         container.register(ItemDataManager.self) { resolver in
//             guard let persistence = resolver.resolve(JSONPersistenceService.self) else {
//                 fatalError("JSONPersistenceService not registered")
//             }
//             return ItemDataManager(persistenceService: persistence)
//         }
//         .inObjectScope(.container)
//     }
// }
