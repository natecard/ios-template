//
//  TemplateItemEntity.swift
//  ios-template
//
//
//  SwiftData model for persisting TemplateItem to local storage.
//  This is OPTIONAL - use when your app needs structured local data storage.
//

import Foundation
import SwiftData

/// SwiftData model for persisting items locally
///
/// Use this when you need:
/// - Offline-first apps (note-taking, journaling, task management)
/// - Complex queries and relationships between data
/// - Data that users create and own (not API-fetched content)
///
/// **Note**: This is optional. For simple apps, use `JSONPersistenceService` for favorites/collections.
///
/// Example usage:
/// ```swift
/// @Query(sort: \TemplateItemEntity.createdDate, order: .reverse)
/// private var items: [TemplateItemEntity]
///
/// // Or manually with ModelContext
/// let context = modelContext
/// let item = TemplateItemEntity(from: templateItem)
/// context.insert(item)
/// try? context.save()
/// ```
@Model
public final class TemplateItemEntity {

    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) public var id: String

    /// Item title
    public var title: String

    /// Brief summary or description
    public var summary: String

    /// Creator or author name
    public var creator: String

    /// Creation date
    public var createdDate: Date

    /// Primary category
    public var primaryCategory: String

    /// All categories/tags
    public var categories: [String]

    /// Whether item has attachment
    public var hasAttachment: Bool

    /// URL to attachment (stored as string for transformable)
    public var attachmentURLString: String?

    // MARK: - Computed Properties

    /// Attachment URL (computed from string)
    public var attachmentURL: URL? {
        get {
            guard let urlString = attachmentURLString else { return nil }
            return URL(string: urlString)
        }
        set {
            attachmentURLString = newValue?.absoluteString
        }
    }

    // MARK: - Initialization

    public init(
        id: String,
        title: String,
        summary: String,
        creator: String,
        createdDate: Date,
        categories: [String] = [],
        primaryCategory: String = "General",
        hasAttachment: Bool = false,
        attachmentURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.creator = creator
        self.createdDate = createdDate
        self.categories = categories
        self.primaryCategory = primaryCategory
        self.hasAttachment = hasAttachment
        self.attachmentURLString = attachmentURL?.absoluteString
    }

    /// Create from TemplateItem
    public convenience init(from item: TemplateItem) {
        self.init(
            id: item.id,
            title: item.title,
            summary: item.summary,
            creator: item.creator,
            createdDate: item.createdDate,
            categories: item.categories,
            primaryCategory: item.primaryCategory,
            hasAttachment: item.hasAttachment,
            attachmentURL: item.attachmentURL
        )
    }

    // MARK: - Conversion

    /// Convert to TemplateItem
    public func toTemplateItem() -> TemplateItem {
        TemplateItem(
            id: id,
            title: title,
            summary: summary,
            creator: creator,
            createdDate: createdDate,
            categories: categories,
            primaryCategory: primaryCategory,
            hasAttachment: hasAttachment,
            attachmentURL: attachmentURL
        )
    }
}

// MARK: - Query Helpers

extension TemplateItemEntity {

    /// Predicate for filtering by category
    public static func predicateForCategory(_ category: String) -> Predicate<TemplateItemEntity> {
        #Predicate<TemplateItemEntity> { item in
            item.primaryCategory == category || item.categories.contains(category)
        }
    }

    /// Predicate for searching by text
    public static func predicateForSearch(_ query: String) -> Predicate<TemplateItemEntity> {
        #Predicate<TemplateItemEntity> { item in
            item.title.localizedStandardContains(query) || item.summary.localizedStandardContains(query)
                || item.creator.localizedStandardContains(query)
        }
    }

    /// Sort descriptor for most recent first
    public static var sortByNewest: SortDescriptor<TemplateItemEntity> {
        SortDescriptor(\.createdDate, order: .reverse)
    }

    /// Sort descriptor for title alphabetically
    public static var sortByTitle: SortDescriptor<TemplateItemEntity> {
        SortDescriptor(\.title, order: .forward)
    }
}
