//
//  PurchaseManager.swift
//  ios-template
//
//
//

import Foundation
import Observation
import StoreKit

// MARK: - Server Validation Request

private struct IAPValidationRequest: Encodable, Sendable {
    let transactionId: String
    let productId: String
    let revoked: Bool
}

// MARK: - Purchase Manager

@MainActor
@Observable

public final class PurchaseManager {
    // MARK: - Product IDs
    enum ProductId {
        /// Product identifier - reads from Info.plist key "IAPProductID"
        /// Set this in your Info.plist to match your App Store Connect product identifier
        static var fullUnlock: String {
            guard let productId = Bundle.main.object(forInfoDictionaryKey: "IAPProductID") as? String,
                !productId.isEmpty
            else {
                // Uncomment this line below and remove the other lines once you have your IAPProductID from App Connect
                print("⚠️ IAPProductID not found in Info.plist. Please add your product identifier.")
                return "com.example.app.fullunlock"  // Placeholder for development/testing
                // fatalError("IAPProductID not found in Info.plist. Please add your product identifier.")
            }
            return productId
        }
    }

    // MARK: - Persistent Unlock State
    private let unlockKey = "fullAppUnlocked"
    private let transactionIdKey = "fullUnlockTransactionId"
    private let sandboxOverrideKey = "iapSandboxOverrideEnabled"

    var isFullAppUnlocked: Bool {
        get { UserDefaults.standard.bool(forKey: unlockKey) }
        set { UserDefaults.standard.set(newValue, forKey: unlockKey) }
    }

    var lastFullUnlockTransactionId: String? {
        get { UserDefaults.standard.string(forKey: transactionIdKey) }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: transactionIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: transactionIdKey)
            }
        }
    }

    /// Set this flag via debug UI or LLDB to force posting to the sandbox endpoint
    var isSandboxOverrideEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: sandboxOverrideKey) }
        set { UserDefaults.standard.set(newValue, forKey: sandboxOverrideKey) }
    }

    // MARK: - StoreKit State
    private(set) var fullUnlockProduct: Product?
    private var updatesTask: Task<Void, Never>?
    var isProcessingPurchase: Bool = false
    var isProcessingRestore: Bool = false

    // MARK: - Paywall Presentation State
    var isPaywallPresented: Bool = false
    var paywallSource: String?

    // MARK: - Lifecycle
    func start() {
        // Load products and begin listening to transaction updates
        updatesTask?.cancel()
        updatesTask = Task { [weak self] in
            #if DEBUG
                // Default to sandbox validation in DEBUG unless explicitly set
                if let self, UserDefaults.standard.object(forKey: sandboxOverrideKey) == nil {
                    self.isSandboxOverrideEnabled = true
                }
            #endif
            await self?.refreshProducts()
            // Sync current entitlements at startup to reflect existing purchases
            await self?.updateEntitlementsFromCurrentTransactions()
            await self?.listenForTransactions()
        }
    }

    deinit {}

    // MARK: - Products
    func refreshProducts() async {
        do {
            let products = try await Product.products(for: [ProductId.fullUnlock])
            fullUnlockProduct = products.first
        } catch {
            print("StoreKit: Failed to load products: \(error.localizedDescription)")
        }
    }

    // MARK: - Purchasing
    @discardableResult
    func purchaseFullUnlock() async -> Bool {
        do {
            isProcessingPurchase = true
            defer { isProcessingPurchase = false }
            if fullUnlockProduct == nil { await refreshProducts() }
            guard let product = fullUnlockProduct else {
                return false
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                do {
                    let transaction = try self.checkVerified(verification)
                    await transaction.finish()
                    isFullAppUnlocked = true
                    lastFullUnlockTransactionId = String(transaction.id)
                    postValidationToServer(
                        transactionId: String(transaction.id),
                        productId: transaction.productID,
                        revoked: false
                    )
                    return true
                } catch {
                    print("StoreKit: Transaction verification failed: \(error.localizedDescription)")
                    #if DEBUG
                        // For StoreKit Testing, try to extract transaction ID even if unverified (DEBUG only). Do not post to server.
                        if case .unverified(let unverifiedTransaction, let verificationError) = verification {
                            print(
                                """
                                  StoreKit: Unverified transaction detected
                                  id: \(unverifiedTransaction.id),
                                  productID: \(unverifiedTransaction.productID),
                                  bundleID: \(Bundle.main.bundleIdentifier ?? "unknown"),
                                  error: \(verificationError.localizedDescription)
                                """
                            )
                            print(
                                """
                                  StoreKit: Unverified transaction details
                                  originalID=\(unverifiedTransaction.originalID),
                                  webOrderLineItemID=\(unverifiedTransaction.webOrderLineItemID ?? "none"),
                                  purchaseDate=\(unverifiedTransaction.purchaseDate),
                                  environment=\(unverifiedTransaction.environment.rawValue)
                                """
                            )
                            await unverifiedTransaction.finish()
                            isFullAppUnlocked = true
                            lastFullUnlockTransactionId = String(unverifiedTransaction.id)
                            return true
                        }
                    #endif
                    return false
                }
            case .userCancelled:
                print("StoreKit: Purchase cancelled by user")
                return false
            case .pending:
                print("StoreKit: Purchase pending")
                return false
            @unknown default:
                return false
            }
        } catch {
            print("StoreKit: purchase failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Paywall Control
    func presentPaywall(source: String? = nil) {
        paywallSource = source
        isPaywallPresented = true
        Task { await refreshProducts() }
    }

    func dismissPaywall() {
        isPaywallPresented = false
        paywallSource = nil
    }

    func restorePurchases() async {
        isProcessingRestore = true
        defer { isProcessingRestore = false }
        do {
            try await AppStore.sync()
        } catch {
            // Proceed to re-read entitlements even if sync fails; user may still be entitled locally
        }
        await updateEntitlementsFromCurrentTransactions(forceLockIfAbsent: true)
    }

    // MARK: - Transaction Listening
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == ProductId.fullUnlock {
                    if transaction.revocationDate != nil {
                        // Purchase was revoked (refund or other reason)
                        isFullAppUnlocked = false
                        lastFullUnlockTransactionId = nil
                        print("StoreKit: Transaction revoked id=\(transaction.id)")
                        postValidationToServer(
                            transactionId: String(transaction.id),
                            productId: transaction.productID,
                            revoked: true
                        )
                    } else {
                        print("StoreKit: Transaction update verified id=\(transaction.id)")
                        isFullAppUnlocked = true
                        lastFullUnlockTransactionId = String(transaction.id)
                        postValidationToServer(
                            transactionId: String(transaction.id),
                            productId: transaction.productID,
                            revoked: false
                        )
                    }
                }
                await transaction.finish()
            } catch {
                print("StoreKit: Transaction update verification failed: \(error.localizedDescription)")
                #if DEBUG
                    // Handle unverified transactions for StoreKit Testing (DEBUG only). Do not post to server.
                    if case .unverified(let unverifiedTransaction, let verificationError) = result {
                        print(
                            """
                            StoreKit: Unverified transaction update
                              id: \(unverifiedTransaction.id), error: \(verificationError.localizedDescription)
                            """
                        )
                        if unverifiedTransaction.productID == ProductId.fullUnlock {
                            if unverifiedTransaction.revocationDate != nil {
                                isFullAppUnlocked = false
                                lastFullUnlockTransactionId = nil
                            } else {
                                isFullAppUnlocked = true
                                lastFullUnlockTransactionId = String(unverifiedTransaction.id)
                            }
                        }
                        await unverifiedTransaction.finish()
                    }
                #endif
            }
        }
    }

    // MARK: - Helpers
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw NSError(
                domain: "PurchaseManager",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Unverified transaction"]
            )
        case .verified(let safe):
            return safe
        }
    }

    /// Reads current entitlements and updates unlock state.
    /// - Parameter forceLockIfAbsent: If true, sets unlocked = false when entitlement not found.
    ///   Use true after a successful restore/sync to reflect server state.
    /// Keep false at startup to avoid offline regressions.
    func updateEntitlementsFromCurrentTransactions(forceLockIfAbsent: Bool = false) async {
        var foundFullUnlock = false
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == ProductId.fullUnlock {
                    if transaction.revocationDate != nil {
                        // If a revoked transaction somehow appears here, treat as locked
                        isFullAppUnlocked = false
                        lastFullUnlockTransactionId = nil
                        postValidationToServer(
                            transactionId: String(transaction.id),
                            productId: transaction.productID,
                            revoked: true
                        )
                    } else {
                        foundFullUnlock = true
                        isFullAppUnlocked = true
                        lastFullUnlockTransactionId = String(transaction.id)
                        postValidationToServer(
                            transactionId: String(transaction.id),
                            productId: transaction.productID,
                            revoked: false
                        )
                    }
                }
            } catch {
                print("StoreKit: Entitlement verification failed: \(error.localizedDescription)")
                #if DEBUG
                    // Handle unverified transactions for StoreKit Testing (DEBUG only). Do not post to server.
                    if case .unverified(let unverifiedTransaction, let verificationError) = result {
                        print(
                            """
                              StoreKit: Unverified entitlement
                              id: \(unverifiedTransaction.id), error: \(verificationError.localizedDescription)
                            """
                        )
                        if unverifiedTransaction.productID == ProductId.fullUnlock {
                            if unverifiedTransaction.revocationDate != nil {
                                isFullAppUnlocked = false
                                lastFullUnlockTransactionId = nil
                            } else {
                                foundFullUnlock = true
                                isFullAppUnlocked = true
                                lastFullUnlockTransactionId = String(unverifiedTransaction.id)
                            }
                        }
                    }
                #endif
            }
        }
        if forceLockIfAbsent && foundFullUnlock == false {
            isFullAppUnlocked = false
            lastFullUnlockTransactionId = nil
        }
    }

    /// Re-posts the latest known full unlock transaction to the validation server.
    /// Uses stored id if available; otherwise queries StoreKit for the latest/current entitlement.
    func resendValidationOfLatestFullUnlock() async {
        if let txId = lastFullUnlockTransactionId {
            postValidationToServer(transactionId: txId, productId: ProductId.fullUnlock, revoked: false)
            return
        }

        if let latest = await Transaction.latest(for: ProductId.fullUnlock) {
            switch latest {
            case .verified(let trans):
                lastFullUnlockTransactionId = String(trans.id)
                isFullAppUnlocked = (trans.revocationDate == nil)
                postValidationToServer(
                    transactionId: String(trans.id),
                    productId: trans.productID,
                    revoked: (trans.revocationDate != nil)
                )
                return
            #if DEBUG
                case .unverified(let unverifiedTrans, let error):
                    print(
                        "StoreKit: Latest transaction unverified - id: \(unverifiedTrans.id), error: \(error.localizedDescription)"
                    )
                    lastFullUnlockTransactionId = String(unverifiedTrans.id)
                    isFullAppUnlocked = (unverifiedTrans.revocationDate == nil)
                    return
            #else
                case .unverified:
                    break
            #endif
            }
        }

        for await result in Transaction.currentEntitlements {
            do {
                let trans = try checkVerified(result)
                if trans.productID == ProductId.fullUnlock {
                    lastFullUnlockTransactionId = String(trans.id)
                    isFullAppUnlocked = (trans.revocationDate == nil)
                    postValidationToServer(
                        transactionId: String(trans.id),
                        productId: trans.productID,
                        revoked: (trans.revocationDate != nil)
                    )
                    break
                }
            } catch {
                print("StoreKit: Entitlement verification failed in resend: \(error.localizedDescription)")
                #if DEBUG
                    if case .unverified(let unverifiedTrans, let verificationError) = result {
                        print(
                            """
                              "StoreKit: Unverified entitlement in resend
                              id: \(unverifiedTrans.id), error: \(verificationError.localizedDescription)
                            """
                        )
                        if unverifiedTrans.productID == ProductId.fullUnlock {
                            lastFullUnlockTransactionId = String(unverifiedTrans.id)
                            isFullAppUnlocked = (unverifiedTrans.revocationDate == nil)
                            break
                        }
                    }
                #endif
            }
        }
    }

    // MARK: - Account Deletion
    func clearPurchaseData() {
        isFullAppUnlocked = false
        lastFullUnlockTransactionId = nil
        // Note: We intentionally preserve isSandboxOverrideEnabled for debugging purposes
        print("💳 Purchase data cleared - unlock state reset")
        print("📝 Users can still restore purchases using the Restore button")
    }

    // MARK: - Server Validation
    private func postValidationToServer(transactionId: String, productId: String, revoked: Bool) {
        let isSandbox = isSandboxOverrideEnabled
        let key = isSandbox ? "IAPValidationURLSandbox" : "IAPValidationURL"
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: key) as? String,
            !urlString.isEmpty,
            let url = URL(string: urlString)
        else { return }

        let body = IAPValidationRequest(transactionId: transactionId, productId: productId, revoked: revoked)

        guard let bodyData = try? JSONEncoder().encode(body) else { return }

        Task.detached(priority: .utility) {
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = bodyData
                let (_, response) = try await URLSession.shared.data(for: request)
                if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                    print(
                        "IAP validation failed for transaction \(transactionId), product \(productId) status: \(http.statusCode)"
                    )
                }
            } catch {
                print("IAP validation POST failed: \(error)")
            }
        }
    }
}
