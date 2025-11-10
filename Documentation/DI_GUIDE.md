# Dependency Injection Guide

This guide explains how dependency injection (DI) is structured in the template, how to register and resolve services, how to introduce new features safely, and how to test and override dependencies.

The template is dependency-free by default. You can optionally enable container-based DI (for example with Swinject or your preferred framework) and use the provided `@Injected` pattern to bridge the container into SwiftUI views through the environment.

---

## Goals of the DI Layer

1. **Deterministic startup** – All core services are registered in one place.
2. **Testability** – Clear override path without global singletons.
3. **Feature isolation** – Each feature declares only what it needs.
4. **Progressive complexity** – Start small; scale to more modules (networking, auth, analytics) later.
5. **SwiftUI-friendly resolution** – Views declare dependencies explicitly via `@Injected`.

---

## Key Types

| Type | Purpose |
|------|---------|
| `AppContainer` | Wraps the Swinject `Container` and builds preconfigured variants (app / test / preview). |
| `ServiceAssembly` | Protocol each assembly implements to register related services. |
| `InfrastructureAssembly` | Lowest-level cross‑cutting services (logging, networking, schedulers). Currently a placeholder. |
| `DomainAssembly` | Core domain layer (repositories, managers, persistence, purchase system). |
| `TemplateFeatureAssembly` | Registers view models used by the template features (Items, Search, Settings). |
| `AuthenticationAssembly` | Reserved for future auth; empty in the base template. |
| `@Injected` | Property wrapper resolving a dependency from the environment's `AppContainer`. |

---

## Container Lifecycle

Startup path (see `ios_templateApp.swift`):

```
Ios_templateApp
  └─ task performBootstrap()
	   └─ BootstrapActor.bootstrap()
			└─ AppContainer.buildApp()
				 ├─ InfrastructureAssembly
				 ├─ DomainAssembly
				 └─ TemplateFeatureAssembly
```

After bootstrapping, the container is injected into the SwiftUI environment:

```swift
AppTabView()
  .environment(\.appContainer, container)
```

Any view can then use:

```swift
@Injected private var viewModel: ItemsListViewModel
```

If resolution fails, the wrapper triggers a `fatalError` – this is intentional to catch registration problems EARLY in development.

---

## Assemblies

Assemblies group logically related registrations. Order matters when downstream registrations depend on earlier ones. Current order: **Infrastructure → Domain → Feature**.

Example (`DomainAssembly` excerpt):

```swift
container.register(ItemRepository.self) { _ in ItemRepository() }
	.inObjectScope(.container)

container.register(JSONPersistenceService.self) { _ in try! JSONPersistenceService() }
	.inObjectScope(.container)

container.register(ItemDataManager.self) { r in
	let persistence = r.resolve(JSONPersistenceService.self)!
	return ItemDataManager(persistenceService: persistence)
}.inObjectScope(.container)
```

Scopes you will commonly use:

| Scope | Use When | Notes |
|-------|----------|-------|
| `.container` | One shared instance (singleton-like) | For stateless services and managers. |
| `.transient` | New instance per resolution | For lightweight view models. |
| `.graph` | Per object graph (advanced) | Rare in this template; optional for complex cascades. |

---

## Registering a New Service

1. Decide its layer: infrastructure, domain, or feature.
2. Add registration to the appropriate assembly (or create a new assembly if it’s a new vertical slice).
3. Choose scope.
4. Inject into dependent types via initializer or `@Injected` in SwiftUI views (for view models).

Example: Adding an `AnalyticsService`.

```swift
// 1. Define service
protocol AnalyticsService { func track(_ event: String, metadata: [String: String]?) }

final class ConsoleAnalyticsService: AnalyticsService { 
	func track(_ event: String, metadata: [String: String]? = nil) { 
		print("[Analytics]", event, metadata ?? [:])
	}
}

// 2. Register (InfrastructureAssembly)
container.register(AnalyticsService.self) { _ in ConsoleAnalyticsService() }
	.inObjectScope(.container)

// 3. Consume (ViewModel)
struct MyFeatureAssembly: ServiceAssembly {
	func assemble(container: Container) {
		container.register(MyViewModel.self) { r in
			let analytics = r.resolve(AnalyticsService.self)!
			return MyViewModel(analytics: analytics)
		}.inObjectScope(.transient)
	}
}
```

---

## Using `@Injected`

In a view:

```swift
public struct ItemsListView: View {
	@Injected private var viewModel: ItemsListViewModel
	// ...
}
```

Providing a manual instance (useful for previews/tests):

```swift
ItemsListView(viewModel: ItemsListViewModel(
	repository: ItemRepository(),
	dataManager: ItemDataManager(persistenceService: try! JSONPersistenceService())
))
```

The wrapper caches the resolved value for the view’s lifetime, avoiding repeated container lookups.

---

## Testing & Overrides

Use `AppContainer.buildTest(overrides:)` to supply test doubles:

```swift
struct MockDomainAssembly: ServiceAssembly {
	func assemble(container: Container) {
		container.register(ItemRepository.self) { _ in MockItemRepository() }
			.inObjectScope(.container)
	}
}

let testContainer = AppContainer.buildTest(overrides: [MockDomainAssembly()])
let repo: ItemRepository? = testContainer.resolve(ItemRepository.self)
```

You can also bypass DI entirely by injecting concrete dependencies into view initializers for unit/UI tests.

---

## Previews

Use the default preview container or supply lightweight stubs:

```swift
#Preview {
	AppTabView()
		.environment(\.appContainer, AppContainer.buildPreview())
}
```

For a feature-specific preview:

```swift
#Preview("Items List") {
	ItemsListView(viewModel: .preview)
}
```

Extend your view model with a static `.preview` factory returning seeded data.

---

## Errors & Diagnostics

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Crash: "Missing dependency X" | Type not registered or wrong type | Verify registration + generic signature. |
| View model state not shared | Scope is `.transient` but you expected a singleton | Change to `.container`. |
| Multiple instances created | Duplicate registrations | Consolidate into a single assembly entry. |
| Hard to override in tests | Logic inside production assembly only | Extract protocol + inject via override assembly. |

Add targeted unit tests asserting container wiring if your graph grows:

```swift
func testContainerResolvesCoreServices() {
	let c = AppContainer.buildApp()
	XCTAssertNotNil(c.resolve(ItemRepository.self) as ItemRepository?)
	XCTAssertNotNil(c.resolve(ItemDataManager.self) as ItemDataManager?)
}
```

---

## Migration Path (When Scaling Up)

| Need | Evolution |
|------|-----------|
| Async boot (remote config) | Add async setup in `BootstrapActor` before returning container. |
| Feature flags | Register a `FeatureFlagService` in Infrastructure and inject where needed. |
| Multiple environments | Add an `EnvironmentConfiguration` service registered per build config. |
| Analytics / Logging | Central `EventPipeline` registered early; inject adapters downstream. |
| Modularization | Split assemblies into separate Swift Packages; each exposes its own `ServiceAssembly`. |

---

## Design Principles Recap

1. Keep assemblies **narrow** – only register what they own.
2. Make protocols for anything with >1 plausible implementation.
3. Prefer initializer injection for pure Swift types; use `@Injected` only at view boundaries.
4. Do not leak the container globally; restrict access to SwiftUI environment + composition roots.
5. Fail fast on missing registrations to avoid silent logic bugs.

---

## Quick Start (Copy/Paste)

```swift
// 1. Add a service
protocol TimeService { func now() -> Date }
final class SystemTimeService: TimeService { func now() -> Date { Date() } }

// 2. Register in InfrastructureAssembly
container.register(TimeService.self) { _ in SystemTimeService() }
	.inObjectScope(.container)

// 3. Consume in a view model
final class ClockViewModel: ObservableObject {
	private let timeService: TimeService
	init(timeService: TimeService) { self.timeService = timeService }
}

// 4. Register the view model (Feature Assembly)
container.register(ClockViewModel.self) { r in
	ClockViewModel(timeService: r.resolve(TimeService.self)!)
}.inObjectScope(.transient)

// 5. Inject into a view
struct ClockView: View { @Injected private var vm: ClockViewModel; var body: some View { Text(vm.timeService.now(), format: .dateTime) } }
```

---

## See Also

- `STRUCTURE_OVERVIEW.md` – Big picture layout
- `PROTOCOL_GUIDE.md` – Generic protocol ecosystem
- `STORAGE_GUIDE.md` – Persistence strategies
- `INTEGRATION_GUIDE.md` – Adding the template to a project
- `QUICK_REFERENCE.md` – Snippets & shortcuts

---

Need more? Open an issue or extend the assemblies with your domain-specific services.

