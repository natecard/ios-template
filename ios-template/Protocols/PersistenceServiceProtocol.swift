//
//  PersistenceServiceProtocol.swift
//  ios-template
//
//  Generic protocol for persisting items and collections.
//

import Foundation

/// Protocol for persisting items and collections to storage
///
/// Implement this protocol to provide data persistence for your application.
/// The protocol is generic over both Item and Collection types.
///
/// Example implementation using JSON files:
/// ```swift
/// actor JSONPersistenceService<Item: GenericItem, Collection: GenericCollection>: PersistenceServiceProtocol
///     where Collection.Item == Item {
///
///     private let favoritesURL: URL
///     private let collectionsURL: URL
///
///     init() throws {
///         // Set up storage URLs
///         let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
///         let directory = appSupport.appendingPathComponent("YourApp")
///         try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
///
///         favoritesURL = directory.appendingPathComponent("favorites.json")
///         collectionsURL = directory.appendingPathComponent("collections.json")
///     }
///
///     func saveFavorites(_ items: [Item]) async throws {
///         let data = try JSONEncoder().encode(items)
///         try data.write(to: favoritesURL)
///     }
///
///     // Implement other methods...
/// }
/// ```
public protocol PersistenceServiceProtocol<Item, Collection>: Sendable {
    associatedtype Item: GenericItem & Sendable
    associatedtype Collection: GenericCollection & Sendable

    /// Save favorite items to storage
    /// - Parameter items: Array of items to save as favorites
    func saveFavorites(_ items: [Item]) async throws

    /// Load favorite items from storage
    /// - Returns: Array of favorite items, or empty array if none exist
    func loadFavorites() async throws -> [Item]

    /// Save user collections to storage
    /// - Parameter collections: Array of collections to save
    func saveCollections(_ collections: [Collection]) async throws

    /// Load user collections from storage
    /// - Returns: Array of collections, or empty array if none exist
    func loadCollections() async throws -> [Collection]

    /// Clear all persisted data (favorites and collections)
    func clearAllData() async throws
}

// MARK: - Error Types

/// Errors that can occur during persistence operations
public enum PersistenceError: Error, LocalizedError {
    case directoryNotFound
    case fileNotFound
    case invalidData
    case saveFailed(String)
    case loadFailed(String)

    public var errorDescription: String? {
        switch self {
        case .directoryNotFound:
            return "Application Support directory not found"
        case .fileNotFound:
            return "Persistence file not found"
        case .invalidData:
            return "Invalid data format"
        case .saveFailed(let reason):
            return "Save failed: \(reason)"
        case .loadFailed(let reason):
            return "Load failed: \(reason)"
        }
    }
}
