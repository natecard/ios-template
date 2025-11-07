## In‑App Purchases (IAP) – Backend Contract and Client Integration

This directory exposes minimal, strongly typed endpoints to validate StoreKit 2 purchases and receive App Store server notifications. Use this document to implement a robust client integration and to configure production vs sandbox environments.

### Endpoints

- Production
  - POST `/api/iap/validate`
  - POST `/api/iap/notifications`
- Sandbox (optional separate routes)
  - POST `/api/iap/validate/sand`
  - POST `/api/iap/notifications/sand`

Notes:
- The server implementation supports automatic sandbox fallback when validating a transactionId (production endpoint retries sandbox host on 404). Therefore a single production URL is sufficient for the client in most cases.
- Current iOS client posts to a single URL from Info.plist and does not switch between `/validate` and `/validate/sand` automatically.

### Environment variables (server)

Required
- `APPSTORE_ISSUER_ID`: App Store Connect API Key Issuer ID
- `APPSTORE_KEY_ID`: App Store Connect API Key Key ID
- `APPSTORE_PRIVATE_KEY`: App Store Connect API Key in PKCS#8 PEM format
- `APP_BUNDLE_ID`: Your app’s bundle identifier

Optional (enables signature verification for notifications and transaction JWS)
- `APPLE_ROOT_CAS_DER_BASE64`: Comma‑separated base64 of Apple root CAs in DER. If set, server verifies incoming notifications and transaction JWS using `@apple/app-store-server-library`. Without this var, the server still accepts notifications but decodes them without signature verification for development convenience.

Status: APPLE_ROOT_CAS_DER_BASE64 is configured in the server environment.


### Validate purchase – contract

Request
```json
POST /api/iap/validate
{
  "transactionId": "<StoreKit.Transaction.id as string>",
  "productId": "<StoreKit.Product.ID>",
  "revoked": false, // optional; client hints when posting from a revocation path
  "appAccountToken": "<optional UUID you set at purchase time>"
}
```

Response (200)
```json
{
  "isUnlocked": true,
  "productId": "com.example.premium",
  "transactionId": "420000123456789",
  "originalTransactionId": "420000123456700",
  "environment": "Production",
  "revoked": false
}
```

Client should unlock the feature only when `isUnlocked` is true and `revoked` is false. The `environment` returned by Apple will be `Production` or `Sandbox`.

Error responses
- 400 with `{ "error": "transactionId and productId required" }`
- 500 with `{ "error": "..." }` for upstream or unexpected failures (server logs include structured context)

Sandbox validation uses the same request/response, but POST to `/api/iap/validate/sand`.

### iOS client integration (StoreKit 2)

Client configuration
- `Info.plist` keys:
  - `IAPValidationURL` → `.../api/iap/validate`
  - `IAPValidationURLSandbox` → `.../api/iap/validate/sand`
- Product identifier in use: `your_app_full_app_in_app_purchase_unlock`.
- The app uses StoreKit 2 on‑device verification and posts `transactionId`, `productId`, and `revoked` to the server in non‑blocking background tasks.

Environment selection
- The app can be forced to use the sandbox validate endpoint via a runtime override stored in `UserDefaults`:
  - Key: `iapSandboxOverrideEnabled` (Bool)
  - Backed by `PurchaseManager.isSandboxOverrideEnabled`
- How to toggle:
  - In LLDB: `expr -l Swift -- PurchaseManagerBridge.shared.purchaseManagerRef?.isSandboxOverrideEnabled = true`
  - Or add a hidden debug toggle in Settings bound to `@Environment(PurchaseManager.self).isSandboxOverrideEnabled`.

#### Sandbox testing checklist (Apple Sandbox & StoreKit config)

1) App Store Connect
- Create at least one Sandbox tester (Users and Access → Sandbox Testers).
- Ensure the IAP product exists with identifier `your_app_full_app_in_app_purchase_unlock` and is in a valid state.
- Agreements, Tax, and Banking must be active; otherwise StoreKit product fetch returns empty.

2) Device setup
- On device: Settings → App Store → Sandbox Account → Sign in with sandbox tester.
- If previously signed in, sign out/in or use Clear Purchase History if flows are stuck.

3) Xcode StoreKit configuration (for local StoreKit Testing)
- Ensure `configuration.storekit` is included in the target Resources (already added in project).
- In Xcode: Product → Scheme → Edit Scheme… → Run → Options → StoreKit Configuration → select `configuration.storekit`.
- Run on simulator or device; StoreKit Testing will use the local configuration file.

4) Bundle & product IDs
- App bundle id must match what you configured in App Store Connect: `com.yourcompany.yourapp`.
- Product id in code and `configuration.storekit` must match ASC: `your_app_full_app_in_app_purchase_unlock`.

5) Validation endpoint selection
- Debug builds default `isSandboxOverrideEnabled = true`, posting to `IAPValidationURLSandbox`.
- Tap Settings → Version label 5× or use the Debug toggle to switch.
- Confirm the current endpoint shown in Settings → Debug section.

6) Logs
- Product fetch failures: look for "StoreKit: Failed to load products" with the error.
- Server POSTs: look for "IAP validation server responded with status" lines.

Current iOS implementation (excerpts)

Product ID constant:
```9:12:ios-template/Services/Purchases/PurchaseManager.swift
enum ProductId {
    // TODO: Ensure this matches App Store Connect product identifier
    static let fullUnlock = "your_app_full_app_in_app_purchase_unlock"
}
```

Post after successful purchase:
```74:81:ios-template/Services/Purchases/PurchaseManager.swift
case .success(let verification):
    if let transaction = try? self.checkVerified(verification) {
        await transaction.finish()
        isFullAppUnlocked = true
        lastFullUnlockTransactionId = String(transaction.id)
        postValidationToServer(transactionId: String(transaction.id), productId: transaction.productID, revoked: false)
        return true
    }
```

Revocation handling and posting on updates:
```110:121:ios-template/Services/Purchases/PurchaseManager.swift
if transaction.productID == ProductId.fullUnlock {
    if let _ = transaction.revocationDate {
        isFullAppUnlocked = false
        lastFullUnlockTransactionId = nil
        postValidationToServer(transactionId: String(transaction.id), productId: transaction.productID, revoked: true)
    } else {
        isFullAppUnlocked = true
        lastFullUnlockTransactionId = String(transaction.id)
        postValidationToServer(transactionId: String(transaction.id), productId: transaction.productID, revoked: false)
    }
}
```

Entitlement sync at startup/restore posts too:
```145:160:ios-template/Services/Purchases/PurchaseManager.swift
if let transaction = try? checkVerified(result), transaction.productID == ProductId.fullUnlock {
    if let _ = transaction.revocationDate {
        isFullAppUnlocked = false
        lastFullUnlockTransactionId = nil
        postValidationToServer(transactionId: String(transaction.id), productId: transaction.productID, revoked: true)
    } else {
        foundFullUnlock = true
        isFullAppUnlocked = true
        lastFullUnlockTransactionId = String(transaction.id)
        postValidationToServer(transactionId: String(transaction.id), productId: transaction.productID, revoked: false)
    }
}
```

Restore path runs `AppStore.sync()` before re‑reading entitlements:
```96:104:ios-template/Services/Purchases/PurchaseManager.swift
isProcessingRestore = true
defer { isProcessingRestore = false }
do { try await AppStore.sync() } catch {}
await updateEntitlementsFromCurrentTransactions(forceLockIfAbsent: true)
```

Server POST implementation (non‑blocking):
```168:198:ios-template/Services/Purchases/PurchaseManager.swift
private func postValidationToServer(transactionId: String, productId: String, revoked: Bool) {
    guard let urlString = Bundle.main.object(forInfoDictionaryKey: "IAPValidationURL") as? String,
          let url = URL(string: urlString), !urlString.isEmpty, url.host?.contains("example") == false else { return }
    struct RequestBody: Encodable { let transactionId: String; let productId: String; let revoked: Bool }
    let body = RequestBody(transactionId: transactionId, productId: productId, revoked: revoked)
    Task.detached(priority: .utility) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        _ = try await URLSession.shared.data(for: request)
    }
}
```

Persistence
- App persists `isFullAppUnlocked` and `lastFullUnlockTransactionId` in `UserDefaults` for diagnostics and UI gating.

Purchase flow (Swift)
```swift
import StoreKit

func purchase(product: Product) async throws {
    // If you use appAccountToken, create a stable UUID per signed-in user
    let options = PurchaseOptions(appAccountToken: UUID(uuidString: "YOUR-USER-UUID")!)
    let result = try await product.purchase(options: options)

    switch result {
    case .success(let verification):
        let transaction = try checkVerified(verification)
        let txId = String(transaction.id)
        let body: [String: Any] = [
            "transactionId": txId,
            "productId": product.id
        ]

        // Choose endpoint by build/config. For sandbox use /api/iap/validate/sand
        try await callValidate(body: body, endpoint: "https://your.domain/api/iap/validate")

        await transaction.finish()

    case .userCancelled, .pending:
        return
    @unknown default:
        return
    }
}

func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .verified(let signedType):
        return signedType
    case .unverified(_, let error):
        throw error
    }
}

func callValidate(body: [String: Any], endpoint: String) async throws {
    let url = URL(string: endpoint)!
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

    let (data, response) = try await URLSession.shared.data(for: req)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
        throw URLError(.badServerResponse)
    }
    let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    guard (obj["isUnlocked"] as? Bool) == true, (obj["revoked"] as? Bool) == false else {
        throw NSError(domain: "IAP", code: 1)
    }
}
```

Restore flow (Swift)
```swift
import StoreKit

func restoreEntitlements() async throws {
    for await result in Transaction.currentEntitlements {
        if case .verified(let transaction) = result {
            let txId = String(transaction.id)
            let body: [String: Any] = [
                "transactionId": txId,
                "productId": transaction.productID
            ]
            try await callValidate(body: body, endpoint: "https://your.domain/api/iap/validate")
        }
    }
}
```

Notes
- `transaction.id` is the ID required by the backend. Do not send the entire signed JWS from the app.
- If you use `appAccountToken`, pass a stable, per-account UUID at purchase to help the server associate transactions to your user. The current backend accepts the field but does not yet persist it; you can extend the handlers to store this mapping.
- Call validation after each successful purchase and during restore to keep the client’s entitlement model consistent with revocations/refunds.

### Notifications (server‑to‑server)

Configure in App Store Connect
- Production server URL: `.../api/iap/notifications`
- Sandbox server URL (optional): `.../api/iap/notifications/sand`

Behavior
- With `APPLE_ROOT_CAS_DER_BASE64` and `APP_BUNDLE_ID` set (present in env), the server signature‑verifies notifications and embedded `signedTransactionInfo`. Otherwise, it decodes without verification (development fallback).
- Handlers always return HTTP 200 (even on internal errors) to avoid excessive Apple retries. Errors are logged with context; add persistence/retry logic internally if needed.

Persistence hooks
- See `src/app/api/iap/notifications/route.ts` and `.../sand/route.ts`. Where noted, add your DB writes for entitlements, revocations, and refunds using `notificationType`, `subtype`, and decoded transaction payloads.

### cURL examples

Production validation
```bash
curl -X .../api/iap/validate \
  -H 'Content-Type: application/json' \
  -d '{
    "transactionId": "ABCD1234567890",
    "productId": "your_app_full_app_in_app_purchase_unlock"
  }'
```

Sandbox validation (if using separate route)
```bash
curl -X POST .../api/iap/validate/sand \
  -H 'Content-Type: application/json' \
  -d '{
    "transactionId": "ABCD1234567890",
    "productId": "your_app_full_app_in_app_purchase_unlock"
  }'
```

### Operational concerns

- Logging: All routes log with tags: `[iap.validate.prod]`, `[iap.validate.sand]`, `[iap.notifications.prod]`, `[iap.notifications.sand]`. Filter logs on these tags to troubleshoot.
- Timeouts: Apple requires notification handlers to respond within ~20s. Keep handlers lightweight; do async work in background if necessary.
- Rate limits: The server calls Apple’s `inApps/v1/transactions/{transactionId}`; handle transient failures with retries if you extend logic.

### Certificates for verification (optional)

If you want signature verification for notifications and transactions:
1) Obtain Apple root CA certificates (DER) from Apple.
2) Base64‑encode them without line breaks and set as comma‑separated list in `APPLE_ROOT_CAS_DER_BASE64`.


### Extensibility

- To hard‑enforce user binding, require auth on validate, and check `appAccountToken` against your user ID.
- To fully verify transactions on validate routes, integrate `SignedDataVerifier` as done in notifications.
- To correlate logs, add a `X-Request-ID` header and include it in logs.
