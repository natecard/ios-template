import SwiftUI

/// SwiftUI environment key for accessing the app's dependency container.
private struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer? = nil
}

extension EnvironmentValues {
    /// App-wide dependency container available to SwiftUI views.
    /// Optional: when `AppContainer` is commented out, this remains `nil` and `@Injected` cannot resolve from it.
    var appContainer: AppContainer? {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}

/// Property wrapper that resolves a dependency from the container and caches it for the view lifecycle.
@propertyWrapper
struct Injected<Value>: DynamicProperty {
    @Environment(\.appContainer) private var container
    @State private var storage: Value?
    private let preset: Value?

    init() {
        self.preset = nil
    }

    init(wrappedValue: Value) {
        self._storage = State(initialValue: wrappedValue)
        self.preset = wrappedValue
    }

    var wrappedValue: Value {
        if let storage {
            return storage
        }

        if let preset {
            storage = preset
            return preset
        }

        guard let resolved = container?.resolve(Value.self) else {
            fatalError("Missing dependency \(Value.self)")
        }

        storage = resolved
        return resolved
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { storage = $0 }
        )
    }
}
