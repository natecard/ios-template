import Foundation
import Swinject
import Alamofire

struct InfrastructureAssembly: ServiceAssembly {
    func assemble(container: Container) {
        // Networking configuration
        container.register(NetworkConfiguration.self) { _ in
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

            return NetworkConfiguration(baseURLs: baseURLs)
        }.inObjectScope(.container)

        // Network client
        container.register(NetworkClientProtocol.self) { resolver in
            let config = resolver.resolve(NetworkConfiguration.self)!
            return AlamofireNetworkClient(configuration: config)
        }.inObjectScope(.container)
    }
}
