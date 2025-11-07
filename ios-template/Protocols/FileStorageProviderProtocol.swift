//
//  FileStorageProviderProtocol.swift
//  ios-template
//
//  Generic protocol for file storage operations (local and cloud).
//

import Foundation

/// Protocol for storing and retrieving files associated with generic items
///
/// Implement this protocol to provide file storage capabilities for your application.
/// Supports both local and iCloud storage scopes.
///
/// Example implementation:
/// ```swift
/// actor FileStorageProvider<Item: GenericItem>: FileStorageProviderProtocol {
///     func store(data: Data, for item: Item, scope: StorageScope, fileExtension: FileExtension) async throws -> URL {
///         let directory = getDirectory(for: scope)
///         let filename = "\(item.id)\(fileExtension.withDot)"
///         let url = directory.appendingPathComponent(filename)
///         try data.write(to: url)
///         return url
///     }
///
///     // Implement other protocol methods...
/// }
/// ```
public protocol FileStorageProviderProtocol<Item>: Sendable {
    associatedtype Item: GenericItem

    /// Store file data for a specific item
    /// - Parameters:
    ///   - data: The file data to store
    ///   - item: The item this file belongs to
    ///   - scope: Storage location (local or cloud)
    ///   - fileExtension: Type of file being stored
    /// - Returns: URL where the file was stored
    func store(data: Data, for item: Item, scope: StorageScope, fileExtension: FileExtension)
        async throws -> URL

    /// Get the URL for a stored file
    /// - Parameters:
    ///   - item: The item to find the file for
    ///   - scope: Storage location to search
    ///   - fileExtension: Type of file to find
    /// - Returns: URL if the file exists, nil otherwise
    func url(for item: Item, scope: StorageScope, fileExtension: FileExtension) async -> URL?

    /// Check if a file exists for an item
    /// - Parameters:
    ///   - item: The item to check for
    ///   - scope: Storage location to check
    ///   - fileExtension: Type of file to check for
    /// - Returns: True if the file exists
    func exists(for item: Item, scope: StorageScope, fileExtension: FileExtension) async -> Bool

    /// List all files of a specific type in a storage scope
    /// - Parameters:
    ///   - scope: Storage location to list
    ///   - fileExtension: Type of files to list (nil for all files)
    /// - Returns: Array of file URLs
    func listAll(scope: StorageScope, fileExtension: FileExtension?) async -> [URL]

    /// Delete all files in a storage scope
    /// - Parameters:
    ///   - scope: Storage location to clear
    ///   - fileExtension: Type of files to delete (nil for all files)
    func deleteAllFiles(scope: StorageScope, fileExtension: FileExtension?) async throws
}

// MARK: - Default Implementations

extension FileStorageProviderProtocol {
    /// List all files in a scope (regardless of extension)
    public func listAll(scope: StorageScope) async -> [URL] {
        await listAll(scope: scope, fileExtension: nil)
    }

    /// Delete all files in a scope (regardless of extension)
    public func deleteAllFiles(scope: StorageScope) async throws {
        try await deleteAllFiles(scope: scope, fileExtension: nil)
    }
}
