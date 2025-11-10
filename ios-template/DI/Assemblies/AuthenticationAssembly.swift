import Foundation
import Swinject

struct AuthenticationAssembly: ServiceAssembly {
    func assemble(container: Container) {
        // No authentication in the base template; reserved for apps that add it.
    }
}
