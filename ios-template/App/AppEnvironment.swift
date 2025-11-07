//
//  AppEnvironment.swift
//  ios-template
//
//  Central app environment managing dependencies and state.
//

import Foundation
import Observation

/// App-wide environment managing all dependencies
///
/// Initialize this in your app's main file and inject as environment.
@MainActor
@Observable
public final class AppEnvironment {
    
    // MARK: - Services
    
    public let purchaseManager: PurchaseManager
    
    // MARK: - Repositories & Storage
    
    public let repository: ItemRepository
    public let persistenceService: JSONPersistenceService
    public let fileStorage: FileStorageProvider
    
    // MARK: - Data Manager
    
    public let dataManager: ItemDataManager
    
    // MARK: - Initialization
    
    public init() throws {
        // Initialize services
        self.purchaseManager = PurchaseManager()
        
        // Initialize repositories
        self.repository = ItemRepository()
        self.persistenceService = try JSONPersistenceService()
        self.fileStorage = try FileStorageProvider()
        
        // Initialize data manager
        self.dataManager = ItemDataManager(persistenceService: persistenceService)
        
        // Set up purchase manager bridge
        PurchaseManagerBridge.shared.purchaseManagerRef = purchaseManager
    }
    
    // MARK: - Lifecycle
    
    /// Start services (call in app's onAppear)
    ///
    /// Note: `ItemDataManager` currently manages favorites in-memory.
    /// To enable persistence-backed favorites/collections, implement
    /// corresponding load/save methods using `JSONPersistenceService`.
    public func start() {
        purchaseManager.start()
    }
}
