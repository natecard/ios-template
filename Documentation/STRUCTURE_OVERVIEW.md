# Project Structure Overview

This template is a production-ready SwiftUI + MVVM app skeleton with built-in monetization, persistence, and a modern design system.

## Application
- `ios-template/App/` — App entry (`ios_templateApp`) and environment key (`AppDependency.swift`) for DI wiring.

## Features
- `Features/ItemsList` — Primary items list feature (view + view model) using the shared repository and UI components.
- `Features/Search` — Search feature demonstrating query, results, and recent searches.
- `Features/Settings` — Settings and account management, including premium state and data deletion.
- `Features/Monetization` — Paywall and purchase-related screens (using `PurchaseManager`).

## Services
- `Services/Monetization` — In-app purchases, account deletion, and StoreKit integration.
- `Services/Storage` — JSON/file-based persistence and storage abstractions.
- `Services/Security` — Keychain utilities and related helpers.

## Repositories & Data
- `Repositories/` — Item-centric repositories (e.g., `ItemRepository`) and data managers (`ItemDataManager`).
- `Protocols/` — Generic protocols like `GenericItem`, `GenericCollection`, `GenericDataManager`, and storage/sync abstractions.
- `Core/SwiftData/` — **Optional** SwiftData integration for local persistence of user-created content.

### Persistence Architecture
The template supports two persistence strategies:

1. **JSON Persistence** (Default)
   - File: `JSONPersistenceService`
   - Use for: User preferences, favorites, collections, settings
   - Storage: Local file system (Documents directory)
   - Benefits: Simple, portable, version-controllable format

2. **SwiftData** (Opt-in)
   - Files: `Core/SwiftData/TemplateItemEntity.swift`, `SwiftDataConfig.swift`
   - Use for: User-created structured data requiring queries, relationships, or offline-first patterns
   - Storage: SQLite database via SwiftData
   - Benefits: Powerful queries, relationships, automatic schema migration

**Architecture Pattern**: `ItemRepository` (API/network) → SwiftData (optional local storage) → JSON (user preferences)

See `Documentation/STORAGE_GUIDE.md` for detailed comparison and decision matrix.

## UI & Design System
- `DesignSystem/` — Design tokens (colors, typography, spacing, motion).
- `UIComponents/` — Reusable components: buttons, cards, inputs, feedback, modern list/search, settings, web.

## Support
- `Documentation/` — Guides for integration, configuration, customization, and CI/CD.
- `ci-cd/` — Format, lint, and pipeline helper scripts.
- `configuration.storekit` — StoreKit configuration for in-app purchases.
- `ios-templateTests/` & `ios-templateUITests/` — Example tests for views and flows.

## Dependency Injection
- `ios-template/DI/` — Container-based DI using Swinject.
   - `AppContainer.swift` — Builds app/test/preview containers and exposes `resolve(_:)`.
   - `Assemblies/InfrastructureAssembly.swift` — Cross-cutting services (logging, networking, etc.).
   - `Assemblies/DomainAssembly.swift` — Repositories, managers, persistence, purchase system.
   - `Assemblies/TemplateFeatureAssembly.swift` — Feature view models (Items, Search, Settings).
   - `Assemblies/AuthenticationAssembly.swift` — Reserved for auth in real apps.

Order of registration: Infrastructure → Domain → Features.

SwiftUI integration: `AppDependency.swift` provides the `appContainer` environment key and an `@Injected` wrapper for resolving dependencies in views.

See `Documentation/DI_GUIDE.md` for details and examples.
