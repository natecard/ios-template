//
//  AppError.swift
//  ios-template
//
//
//  Domain-specific error types.
//

import Foundation

/// Application-specific errors
///
/// Use this enum to define domain-specific errors that can occur in your application.
public enum AppError: LocalizedError, Equatable {
    // MARK: - Data Errors
    
    case itemNotFound(id: String)
    case collectionNotFound(id: UUID)
    case invalidItemData
    case duplicateItem(id: String)
    
    // MARK: - Network Errors
    
    case networkUnavailable
    case invalidURL(String)
    case serverError(statusCode: Int)
    case decodingError(String)
    
    // MARK: - Storage Errors
    
    case storageError(String)
    case fileNotFound(String)
    case insufficientStorage
    
    // MARK: - Feature Errors
    
    case featureLocked(feature: String)
    case purchaseRequired
    
    // MARK: - LocalizedError Conformance
    
    public var errorDescription: String? {
        switch self {
        // Data Errors
        case .itemNotFound(let id):
            return "Item with ID '\(id)' not found"
        case .collectionNotFound(let id):
            return "Collection with ID '\(id)' not found"
        case .invalidItemData:
            return "Invalid item data format"
        case .duplicateItem(let id):
            return "Item with ID '\(id)' already exists"
            
        // Network Errors
        case .networkUnavailable:
            return "Network connection unavailable"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .serverError(let statusCode):
            return "Server error (Status: \(statusCode))"
        case .decodingError(let message):
            return "Failed to decode data: \(message)"
            
        // Storage Errors
        case .storageError(let message):
            return "Storage error: \(message)"
        case .fileNotFound(let filename):
            return "File not found: \(filename)"
        case .insufficientStorage:
            return "Insufficient storage space"
            
        // Feature Errors
        case .featureLocked(let feature):
            return "Feature '\(feature)' requires premium unlock"
        case .purchaseRequired:
            return "This feature requires a purchase"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection and try again"
        case .serverError:
            return "Please try again later"
        case .insufficientStorage:
            return "Free up storage space and try again"
        case .featureLocked, .purchaseRequired:
            return "Unlock the full app to access this feature"
        default:
            return nil
        }
    }
}
