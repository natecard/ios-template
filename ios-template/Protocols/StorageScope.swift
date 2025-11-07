//
//  StorageScope.swift
//  ios-template
//
//  Defines where files should be stored (local or cloud).
//

import Foundation

/// Defines the storage location for files
///
/// Use this enum to specify whether files should be stored locally or in iCloud.
///
/// Example:
/// ```swift
/// // Store in local app container
/// try await storage.store(data: fileData, for: item, scope: .local, fileExtension: .pdf)
///
/// // Store in iCloud Drive
/// try await storage.store(data: fileData, for: item, scope: .cloud, fileExtension: .pdf)
/// ```
public enum StorageScope: String, Codable, CaseIterable, Sendable {
    case local
    case cloud

    /// Human-readable description
    public var description: String {
        switch self {
        case .local:
            return "Local Storage"
        case .cloud:
            return "iCloud Storage"
        }
    }
}
