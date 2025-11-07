//
//  JSONPersistenceService.swift
//  ios-template
//
//
//
//  JSON-based implementation of PersistenceServiceProtocol.
//

import Foundation

/// JSON file-based persistence service
///
/// Stores favorites and collections as JSON files in the app's Application Support directory.
public actor JSONPersistenceService: PersistenceServiceProtocol {
    public typealias Item = TemplateItem
    public typealias Collection = TemplateItemCollection

    // MARK: - Properties

    private let favoritesURL: URL
    private let collectionsURL: URL

    // MARK: - Initialization

    public init() throws {
        // Get Application Support directory
        guard
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
        else {
            throw PersistenceError.directoryNotFound
        }

        // Create app-specific directory
        let directory = appSupport.appendingPathComponent("ios-template")
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        // Set up file URLs
        favoritesURL = directory.appendingPathComponent("favorites.json")
        collectionsURL = directory.appendingPathComponent("collections.json")
    }

    // MARK: - Favorites

    public func saveFavorites(_ items: [Item]) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(items)
            try data.write(to: favoritesURL, options: .atomic)
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }

    public func loadFavorites() async throws -> [Item] {
        guard FileManager.default.fileExists(atPath: favoritesURL.path) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: favoritesURL)
            return try decoder.decode([Item].self, from: data)
        } catch {
            throw PersistenceError.loadFailed(error.localizedDescription)
        }
    }

    // MARK: - Collections

    public func saveCollections(_ collections: [TemplateItemCollection]) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(collections)
            try data.write(to: collectionsURL, options: .atomic)
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }

    public func loadCollections() async throws -> [TemplateItemCollection] {
        guard FileManager.default.fileExists(atPath: collectionsURL.path) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: collectionsURL)
            return try decoder.decode([TemplateItemCollection].self, from: data)
        } catch {
            throw PersistenceError.loadFailed(error.localizedDescription)
        }
    }

    // MARK: - Clear Data

    public func clearAllData() async throws {
        try? FileManager.default.removeItem(at: favoritesURL)
        try? FileManager.default.removeItem(at: collectionsURL)
    }
}
