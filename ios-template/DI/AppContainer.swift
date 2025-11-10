//
//  AppContainer.swift
//  ios-template
//
// Minimal, dependency-free DI facade used by `@Injected`.
// Real apps can replace/extend this with Swinject or another container.

import Foundation

/// Lightweight container used by the template.
///
/// - Zero dependencies by default.
/// - `resolve` always returns `nil` until you provide your own implementation.
/// - To use Swinject, see the commented example below.
struct AppContainer {
    func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        nil
    }
}

// MARK: - Optional Swinject-based implementation (example)
//
// Uncomment and adapt if you add Swinject:
//
// import Swinject
//
// struct AppContainer {
//     let container: Container
//
//     static func buildApp() -> AppContainer {
//         let container = Container()
//         // InfrastructureAssembly().assemble(container: container)
//         // DomainAssembly().assemble(container: container)
//         // TemplateFeatureAssembly().assemble(container: container)
//         return AppContainer(container: container)
//     }
//
//     func resolve<Service>(_ serviceType: Service.Type) -> Service? {
//         container.resolve(serviceType)
//     }
// }
