//
//  FileStorageProvider.swift
//  ios-template
//
//
//
//  Implementation of FileStorageProviderProtocol for local and iCloud storage.
//

import Foundation

/// File storage provider supporting local and iCloud storage
///
/// Stores files associated with items in either local storage or iCloud Drive.
public actor FileStorageProvider: FileStorageProviderProtocol {
    public typealias Item = TemplateItem

    // MARK: - Properties

    private let localDirectory: URL
    private let cloudDirectory: URL?

    // MARK: - Initialization

    public init() throws {
        // Set up local directory
        guard
            let documents = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else {
            throw PersistenceError.directoryNotFound
        }

        localDirectory = documents.appendingPathComponent("ItemFiles")
        try FileManager.default.createDirectory(
            at: localDirectory,
            withIntermediateDirectories: true
        )

        // Set up iCloud directory if available
        cloudDirectory = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent("ItemFiles")

        if let cloudDir = cloudDirectory {
            try? FileManager.default.createDirectory(
                at: cloudDir,
                withIntermediateDirectories: true
            )
        }
    }

    // MARK: - Storage Operations

    public func store(
        data: Data,
        for item: Item,
        scope: StorageScope,
        fileExtension: FileExtension
    ) async throws -> URL {
        let directory = getDirectory(for: scope)
        let filename = "\(item.id)\(fileExtension.withDot)"
        let url = directory.appendingPathComponent(filename)

        try data.write(to: url, options: .atomic)

        return url
    }

    public func url(
        for item: Item,
        scope: StorageScope,
        fileExtension: FileExtension
    ) async -> URL? {
        let directory = getDirectory(for: scope)
        let filename = "\(item.id)\(fileExtension.withDot)"
        let url = directory.appendingPathComponent(filename)

        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    public func exists(
        for item: Item,
        scope: StorageScope,
        fileExtension: FileExtension
    ) async -> Bool {
        await url(for: item, scope: scope, fileExtension: fileExtension) != nil
    }

    public func listAll(
        scope: StorageScope,
        fileExtension: FileExtension?
    ) async -> [URL] {
        let directory = getDirectory(for: scope)

        guard
            let files = try? FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil
            )
        else {
            return []
        }

        if let ext = fileExtension {
            return files.filter { $0.pathExtension == ext.rawValue }
        }

        return files
    }

    public func deleteAllFiles(
        scope: StorageScope,
        fileExtension: FileExtension?
    ) async throws {
        let files = await listAll(scope: scope, fileExtension: fileExtension)

        for file in files {
            try? FileManager.default.removeItem(at: file)
        }
    }

    // MARK: - Private Helpers

    private func getDirectory(for scope: StorageScope) -> URL {
        switch scope {
        case .local:
            return localDirectory
        case .cloud:
            return cloudDirectory ?? localDirectory
        }
    }
}
