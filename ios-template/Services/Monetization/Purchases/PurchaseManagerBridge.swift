//
//  PurchaseManagerBridge.swift
//  ios-template
//
//
//
import Foundation

// Lightweight bridge to access the environment-provided PurchaseManager from non-View code
// Set from App entry when environment is ready.
enum PurchaseManagerBridge {
    @MainActor static var shared = PurchaseManagerBridgeImpl()
}

final class PurchaseManagerBridgeImpl {
    weak var purchaseManagerRef: AnyObject?

    var purchaseManager: PurchaseManager? {
        return purchaseManagerRef as? PurchaseManager
    }
}
