//
//  GenericItem.swift
//  ios-template
//
//  Generic protocol for any item type in your application.
//  Conform your domain models to this protocol to use the template's UI components.
//

import Foundation

/// Metadata entry for displaying extensible item information
public struct ItemMetadataEntry: Codable, Equatable, Sendable {
    public let id: UUID
    public let key: String
    public let value: String
    public let presentation: Presentation

    public init(key: String, value: String, presentation: Presentation) {
        self.id = UUID()
        self.key = key
        self.value = value
        self.presentation = presentation
    }

    public enum Presentation: String, Codable, Sendable {
        case badge  // Display as a prominent badge (e.g., category, status)
        case tag  // Display as a tag in a collection (e.g., multiple categories)
        case inline  // Display inline with other metadata (e.g., author, date)
    }
}

extension ItemMetadataEntry {
    public enum DisplayStyle {
        case badge
        case tag
        case inline

        fileprivate init(presentation: Presentation) {
            switch presentation {
            case .badge:
                self = .badge
            case .tag:
                self = .tag
            case .inline:
                self = .inline
            }
        }

        fileprivate var presentation: Presentation {
            switch self {
            case .badge:
                return .badge
            case .tag:
                return .tag
            case .inline:
                return .inline
            }
        }
    }

    public var displayStyle: DisplayStyle {
        DisplayStyle(presentation: presentation)
    }

    public init(key: String, value: String, displayStyle: DisplayStyle) {
        self.init(key: key, value: value, presentation: displayStyle.presentation)
    }
}

/// Protocol that defines the minimum requirements for an item to be used with this template's components
///
/// Conform your domain models to this protocol to leverage the complete UI component library,
/// including modern cards, lists, and specialized views.
///
/// Example conformance:
/// ```swift
/// struct Item: GenericItem {
///     var id: String
///     var title: String
///     var summary: String { abstract }
///     var creator: String { primaryAuthor }
///     var createdDate: Date { published }
///     var categories: [String]
///     var primaryCategory: String { domain.rawValue }
///     var hasAttachment: Bool { pdfURL != nil }
///     var attachmentURL: URL? { pdfURL }
///     var metadata: [ItemMetadataEntry] {
///         formattedCategories.map { ItemMetadataEntry(key: "category", value: $0, presentation: .tag) }
///     }
/// }
/// ```
public protocol GenericItem: Codable, Equatable, Identifiable {
    /// Unique identifier for the item
    var id: String { get }

    /// Primary title or name of the item
    var title: String { get }

    /// Brief description or abstract of the item
    var summary: String { get }

    /// Primary creator, author, or artist
    var creator: String { get }

    /// Creation or publication date
    var createdDate: Date { get }

    /// All categories or tags associated with the item
    var categories: [String] { get }

    /// Primary category for badge display
    var primaryCategory: String { get }

    /// Whether the item has an associated file attachment
    var hasAttachment: Bool { get }

    /// URL to the attachment, if available
    var attachmentURL: URL? { get }

    /// Extensible metadata for additional display information
    var metadata: [ItemMetadataEntry] { get }
}

// MARK: - Default Implementations

extension GenericItem {
    /// Default metadata returns empty array (can be overridden for richer display)
    public var metadata: [ItemMetadataEntry] {
        []
    }
}
