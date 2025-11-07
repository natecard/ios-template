//
//  AccountDeletionService.swift
//  ios-template
//
//
//

import Foundation

// MARK: - Account Deletion Service

/// Service for deleting all user data including preferences, files, collections, and purchase data
///
/// Generic over Item and Collection types to work with any domain model.
///
/// Example usage:
/// ```swift
/// let deletionService = AccountDeletionService(
///     persistenceService: persistenceService,
///     fileStorageProvider: fileStorageProvider,
///     syncService: syncService,
///     purchaseManager: purchaseManager
/// )
/// try await deletionService.deleteAllUserData()
/// ```
actor AccountDeletionService<Item: GenericItem, Collection: GenericCollection>
where Collection.Item == Item {
    private let persistenceService: any PersistenceServiceProtocol<Item, Collection>
    private let fileStorageProvider: any FileStorageProviderProtocol<Item>
    private let syncService: (any SyncServiceProtocol)?
    private let purchaseManager: PurchaseManager

    init(
        persistenceService: any PersistenceServiceProtocol<Item, Collection>,
        fileStorageProvider: any FileStorageProviderProtocol<Item>,
        syncService: (any SyncServiceProtocol)?,
        purchaseManager: PurchaseManager
    ) {
        self.persistenceService = persistenceService
        self.fileStorageProvider = fileStorageProvider
        self.syncService = syncService
        self.purchaseManager = purchaseManager
    }

    // MARK: - Main Deletion Method

    /// Deletes all user data including preferences, PDFs, collections, and purchase data.
    /// Preserves transaction history to allow purchase restoration.
    func deleteAllUserData() async throws {
        print("🗑️ Starting account deletion process...")

        do {
            // Step 1: Clear persistence data (favorites and collections)
            print("📁 Clearing persistence data...")
            try await persistenceService.clearAllData()
            print("✅ Persistence data cleared")

            // Step 2: Clear all PDF files (both local and iCloud)
            print("📄 Clearing PDF files...")
            try await deleteAllPDFFiles()
            print("✅ PDF files cleared")

            // Step 3: Clear purchase data
            print("💳 Clearing purchase data...")
            await clearPurchaseData()
            print("✅ Purchase data cleared")

            // Step 4: Clear Apple Sign-In credentials
            print("🔐 Clearing Apple Sign-In credentials...")
            clearAppleSignIn()
            print("✅ Apple Sign-In cleared")

            // Step 5: Clear UserDefaults preferences
            print("⚙️ Clearing preferences...")
            clearUserDefaults()
            print("✅ Preferences cleared")

            // Step 6: Reset onboarding state
            print("🎯 Resetting onboarding state...")
            UserDefaults.standard.set(false, forKey: "userOnboarded")
            UserDefaults.standard.set(false, forKey: "hasShownCoachmarks")
            print("✅ Onboarding reset")

            print("🎉 Account deletion completed successfully")
        } catch {
            print("❌ Account deletion failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Private Deletion Methods

    private func deleteAllPDFFiles() async throws {
        // Delete local files
        do {
            print("  📍 Deleting local files...")
            try await fileStorageProvider.deleteAllFiles(scope: .local, fileExtension: nil)
            print("    ✅ Local files deleted")
        } catch {
            print("    ⚠️ Failed to delete local files: \(error.localizedDescription)")
            throw error
        }

        // Delete iCloud files if sync is enabled
        if let syncService = syncService, await syncService.isCloudAvailable() {
            do {
                print("  ☁️ Deleting iCloud files...")
                try await fileStorageProvider.deleteAllFiles(scope: .cloud, fileExtension: nil)
                print("    ✅ iCloud files deleted")
            } catch {
                print("    ⚠️ Failed to delete iCloud files: \(error.localizedDescription)")
                throw error
            }
        }
    }

    private func clearPurchaseData() async {
        // Clear unlock state and transaction ID, but preserve sandbox override for debugging
        await purchaseManager.clearPurchaseData()
    }

    private func clearAppleSignIn() {
        _ = KeychainUtility.clearAppleUserID()
    }

    private func clearUserDefaults() {
        let defaults = UserDefaults.standard

        // Search-related preferences
        defaults.removeObject(forKey: "defaultSearchTerm")
        defaults.removeObject(forKey: "defaultSearchDomain")
        defaults.removeObject(forKey: "defaultSearchSubject")

        // Sort preferences
        defaults.removeObject(forKey: "currentSortBy")
        defaults.removeObject(forKey: "currentSortOrder")

        // Display preferences
        defaults.removeObject(forKey: "darkModeEnabled")
        defaults.removeObject(forKey: "fontSize")

        // HTML resolver preference
        defaults.removeObject(forKey: "lastHTMLResolverMode")

        // Cloud sync preference
        defaults.removeObject(forKey: "cloudSyncEnabled")

        // Sharing preferences
        defaults.removeObject(forKey: "defaultShareFileNameStyle")
        defaults.removeObject(forKey: "shareIncludeAppBranding")

        // Apple user info
        defaults.removeObject(forKey: "appleUserEmail")
        defaults.removeObject(forKey: "appleUserName")

        // Sync database (if it exists)
        defaults.removeObject(forKey: "syncDatabase")
    }
}

// MARK: - Error Types

enum AccountDeletionError: Error, LocalizedError {
    case persistenceError(Error)
    case pdfDeletionError(Error)
    case purchaseError(Error)

    var errorDescription: String? {
        switch self {
        case .persistenceError(let error):
            return "Failed to clear persistence data: \(error.localizedDescription)"
        case .pdfDeletionError(let error):
            return "Failed to delete PDF files: \(error.localizedDescription)"
        case .purchaseError(let error):
            return "Failed to clear purchase data: \(error.localizedDescription)"
        }
    }
}
