import Foundation
import Swinject

/// Central dependency injection container for the application.
///
/// Built via factory methods (app / test / preview) instead of a global singleton.
struct AppContainer {
    let container: Container

    // MARK: - Factories

    static func buildApp() -> AppContainer {
        let container = Container()
        registerAppAssemblies(in: container)
        return AppContainer(container: container)
    }

    static func buildTest(overrides: [ServiceAssembly] = []) -> AppContainer {
        let container = Container()
        registerAppAssemblies(in: container)
        overrides.forEach { $0.assemble(container: container) }
        return AppContainer(container: container)
    }

    static func buildPreview() -> AppContainer {
        let container = Container()
        registerAppAssemblies(in: container)
        return AppContainer(container: container)
    }

    // MARK: - Registration

    private static func registerAppAssemblies(in container: Container) {
        // Order: infrastructure -> domain -> features
        InfrastructureAssembly().assemble(container: container)
        DomainAssembly().assemble(container: container)
        TemplateFeatureAssembly().assemble(container: container)
    }

    // MARK: - Resolution

    func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        container.resolve(serviceType)
    }
}

/// Protocol for service assemblies
protocol ServiceAssembly {
    func assemble(container: Container)
}

actor BootstrapActor {
    static let shared = BootstrapActor()

    func bootstrap() async throws -> AppContainer {
        // For the template, just build the container synchronously.
        // Real apps can extend this to perform async setup.
        return await AppContainer.buildApp()
    }
}
