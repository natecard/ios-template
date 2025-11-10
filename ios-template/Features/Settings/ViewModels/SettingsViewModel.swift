//
//  SettingsViewModel.swift
//  ios-template
//
//  ViewModel for settings screen.
//

import Foundation
import Observation

/// ViewModel for the settings screen
///
/// Manages app settings, purchases, and account deletion.
@Observable
public final class SettingsViewModel {

    // MARK: - Published State

    public var showingDeleteConfirmation = false
    public var isDeleting = false
    public var deleteError: String?

    // MARK: - Dependencies

    private let purchaseManager: PurchaseManager
    private let dataManager: ItemDataManager
    private let fileStorage: FileStorageProvider?

    // MARK: - Computed Properties
    @MainActor
    public var isPremium: Bool {
        purchaseManager.isFullAppUnlocked
    }

    // MARK: - Initialization

    init(
        purchaseManager: PurchaseManager,
        dataManager: ItemDataManager,
        fileStorage: FileStorageProvider? = nil
    ) {
        self.purchaseManager = purchaseManager
        self.dataManager = dataManager
        self.fileStorage = fileStorage
    }

    // MARK: - Actions

    /// Show unlock paywall
    @MainActor public func showPaywall() {
        purchaseManager.presentPaywall(source: "settings")
    }

    /// Restore purchases
    public func restorePurchases() async {
        await purchaseManager.restorePurchases()
    }

    /// Delete all user data
    public func deleteAllData() async {
        isDeleting = true
        deleteError = nil

        defer { isDeleting = false }

        do {
            // Clear data manager
            dataManager.removeAllCollections()

            // Clear file storage
            if let storage = fileStorage {
                try await storage.deleteAllFiles(scope: .local, fileExtension: nil)
                try await storage.deleteAllFiles(scope: .cloud, fileExtension: nil)
            }

            // Clear purchase data
            await purchaseManager.clearPurchaseData()

        } catch {
            deleteError = error.localizedDescription
        }
    }
}
