# Networking Guide

This template includes a simple, production-friendly networking layer built on top of Alamofire and Swinject.
All call sites depend on `NetworkClientProtocol` and repositories/services — never on Alamofire directly.

## Goals

- Single, testable HTTP client abstraction
- Centralized base URL and environment configuration
- Clear error mapping into `AppError`
- Support for sandbox vs production IAP validation
- Remote + local pattern hidden behind repository protocols

## Core Concepts

### NetworkBaseURL

Defined in `Protocols/NetworkClientProtocol.swift`:

- `.default` — primary API base URL
- `.purchases` — production IAP validation base URL
- `.purchasesSandbox` — sandbox IAP validation base URL

Use these cases instead of hard-coding URLs at call sites.

### NetworkConfiguration

`NetworkConfiguration` maps `NetworkBaseURL` values to concrete URLs:

- Built in `InfrastructureAssembly` from Info.plist keys:
  - `APIBaseURL` → `.default`
  - `IAPValidationURL` → `.purchases`
  - `IAPValidationURLSandbox` → `.purchasesSandbox` (optional)
- `url(for:)` falls back to `.default` if a specific base is not set.

### NetworkClientProtocol

A small abstraction over HTTP used across the app:

- `get(_:base:query:)` — generic GET
- `post(_:base:body:query:)` — POST with Encodable body and Decodable response
- `post(_:base:body:headers:)` — POST with raw Data body

Concrete callers never see Alamofire APIs; they depend only on this protocol.

### AlamofireNetworkClient

Located in `Services/Networking/AlamofireNetworkClient.swift`:

- Implements `NetworkClientProtocol` using Alamofire `Session`.
- Builds URLs from `NetworkConfiguration` + `NetworkBaseURL`.
- Uses async/await with `responseData().validate()`.
- Maps common failures into `AppError`:
  - Connectivity issues → `.networkUnavailable`
  - Non-2xx status codes → `.serverError(statusCode:)`
  - Decoding failures → `.decodingError(...)`
  - Invalid URL → `.invalidURL(...)`

This keeps error handling consistent and friendly for UI layers.

## Dependency Injection

Wired via Swinject in `InfrastructureAssembly` and `DomainAssembly`:

- `InfrastructureAssembly`:
  - Registers `NetworkConfiguration` as `.container` using Info.plist values.
  - Registers `NetworkClientProtocol` as `.container` implemented by `AlamofireNetworkClient`.
- `DomainAssembly`:
  - Injects `NetworkClientProtocol` into:
    - `ItemRepository` (remote + cache pattern)
    - `PurchaseManager` (IAP server validation)

Call sites resolve repositories/managers via `@Injected` / container, not the client directly.

## Usage Examples

### Items: Remote + Local via ItemRepository

`ItemRepository` implements `ItemRepositoryProtocol` as an `actor`:

- Fetches items from the network using `NetworkClientProtocol.get("items", base: .default, ...)`.
- Caches the results in-memory for a short duration.
- On failure, falls back to stale cached data when available.
- Exposes a simple API to features:
  - `fetchItems()`
  - `fetchItem(id:)`
  - `searchItems(query:)`
  - `fetchItems(category:)`

Features interact only with `ItemRepositoryProtocol` — the remote/local details are hidden.

### Purchases: IAP Validation

`PurchaseManager` uses `NetworkClientProtocol` for optional server-side validation:

- Chooses base URL:
  - `.purchases` for production
  - `.purchasesSandbox` when sandbox override is enabled
- Sends `IAPValidationRequest` via `post(_:base:body:headers:)` on a background task.

This keeps StoreKit-specific logic separate from networking implementation details.

## Mocking & Testing

Because all callers depend on `NetworkClientProtocol`, mocking is straightforward.

### Basic Mock Client

Create a simple mock in your test target or a demo configuration:

```swift
final class MockNetworkClient: NetworkClientProtocol {
    var getHandler: ((String, NetworkBaseURL, [String: String]?) throws -> Any)?

    func get<T: Decodable>(_ path: String, base: NetworkBaseURL, query: [String: String]?) async throws -> T {
        if let handler = getHandler {
            if let result = try handler(path, base, query) as? T { return result }
        }
        throw AppError.networkUnavailable
    }

    func post<T: Decodable, Body: Encodable>(
        _ path: String,
        base: NetworkBaseURL,
        body: Body?,
        query: [String: String]?
    ) async throws -> T {
        throw AppError.networkUnavailable
    }

    func post(
        _ path: String,
        base: NetworkBaseURL,
        body: Data?,
        headers: [String: String]?
    ) async throws {
        // no-op or throw as needed
    }
}
```

### Using the Mock with Swinject

For tests:

- Create a `MockNetworkingAssembly` that registers `NetworkClientProtocol` with `MockNetworkClient`.
- Build your container with `AppContainer.buildTest(overrides: [MockNetworkingAssembly()])`.
- Resolve repositories/view models as usual; they will receive the mock client.

This approach keeps networking testable and aligned with the rest of the DI architecture.

---

For advanced needs (authentication headers, request logging, retries), extend `AlamofireNetworkClient` or wrap it with additional decorators while keeping the `NetworkClientProtocol` surface stable.
