//
//  SwiftDataTests.swift
//  ios-templateTests
//
//
//  Unit tests demonstrating SwiftData usage with in-memory containers.
//

import Foundation
import SwiftData
import Testing

@testable import ios_template

/// Tests for SwiftData functionality
///
/// These tests use in-memory containers to avoid persistent state between test runs.
@Suite("SwiftData Functionality Tests")
struct SwiftDataTests {

    let container: ModelContainer
    let context: ModelContext

    // MARK: - Setup

    init() throws {
        // Create in-memory container for testing
        container = try SwiftDataConfig.inMemoryContainer()
        context = ModelContext(container)
    }

    // MARK: - Basic CRUD Tests

    @Test("Insert item into SwiftData")
    func insertItem() throws {
        // Given
        let item = TemplateItemEntity(
            id: "test-1",
            title: "Test Item",
            summary: "This is a test summary",
            creator: "Test Author",
            createdDate: Date(),
            categories: ["Test", "Example"],
            primaryCategory: "Test"
        )

        // When
        context.insert(item)
        try context.save()

        // Then
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>()
        let items = try context.fetch(fetchDescriptor)

        #expect(items.count == 1)
        #expect(items.first?.id == "test-1")
        #expect(items.first?.title == "Test Item")
    }

    @Test("Fetch specific item by ID")
    func fetchItem() throws {
        // Given
        let item1 = TemplateItemEntity(
            id: "test-1",
            title: "First Item",
            summary: "First summary",
            creator: "Author 1",
            createdDate: Date()
        )

        let item2 = TemplateItemEntity(
            id: "test-2",
            title: "Second Item",
            summary: "Second summary",
            creator: "Author 2",
            createdDate: Date()
        )

        context.insert(item1)
        context.insert(item2)
        try context.save()

        // When
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>(
            predicate: #Predicate { $0.id == "test-1" }
        )
        let items = try context.fetch(fetchDescriptor)

        // Then
        #expect(items.count == 1)
        #expect(items.first?.title == "First Item")
    }

    @Test("Update item properties")
    func updateItem() throws {
        // Given
        let item = TemplateItemEntity(
            id: "test-1",
            title: "Original Title",
            summary: "Original summary",
            creator: "Author",
            createdDate: Date()
        )

        context.insert(item)
        try context.save()

        // When
        item.title = "Updated Title"
        try context.save()

        // Then
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>()
        let items = try context.fetch(fetchDescriptor)

        #expect(items.first?.title == "Updated Title")
    }

    @Test("Delete item from context")
    func deleteItem() throws {
        // Given
        let item = TemplateItemEntity(
            id: "test-1",
            title: "Test Item",
            summary: "Test summary",
            creator: "Author",
            createdDate: Date()
        )

        context.insert(item)
        try context.save()

        // When
        context.delete(item)
        try context.save()

        // Then
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>()
        let items = try context.fetch(fetchDescriptor)

        #expect(items.count == 0)
    }

    // MARK: - Query Tests

    @Test("Filter items by category")
    func filterByCategory() throws {
        // Given
        let techItem = TemplateItemEntity(
            id: "tech-1",
            title: "Tech Item",
            summary: "Tech summary",
            creator: "Tech Author",
            createdDate: Date(),
            primaryCategory: "Technology"
        )

        let scienceItem = TemplateItemEntity(
            id: "science-1",
            title: "Science Item",
            summary: "Science summary",
            creator: "Science Author",
            createdDate: Date(),
            primaryCategory: "Science"
        )

        context.insert(techItem)
        context.insert(scienceItem)
        try context.save()

        // When
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>(
            predicate: #Predicate { $0.primaryCategory == "Technology" }
        )
        let items = try context.fetch(fetchDescriptor)

        // Then
        #expect(items.count == 1)
        #expect(items.first?.title == "Tech Item")
    }

    @Test("Sort items by date")
    func sortByDate() throws {
        // Given
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!

        let item1 = TemplateItemEntity(
            id: "1",
            title: "Yesterday",
            summary: "Old",
            creator: "Author",
            createdDate: yesterday
        )

        let item2 = TemplateItemEntity(
            id: "2",
            title: "Tomorrow",
            summary: "New",
            creator: "Author",
            createdDate: tomorrow
        )

        let item3 = TemplateItemEntity(
            id: "3",
            title: "Today",
            summary: "Current",
            creator: "Author",
            createdDate: now
        )

        context.insert(item1)
        context.insert(item2)
        context.insert(item3)
        try context.save()

        // When - Sort newest first
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        let items = try context.fetch(fetchDescriptor)

        // Then
        #expect(items.count == 3)
        #expect(items[0].title == "Tomorrow")
        #expect(items[1].title == "Today")
        #expect(items[2].title == "Yesterday")
    }

    @Test("Search items by text content")
    func searchByText() throws {
        // Given
        let item1 = TemplateItemEntity(
            id: "1",
            title: "SwiftUI Tutorial",
            summary: "Learn SwiftUI basics",
            creator: "Apple",
            createdDate: Date()
        )

        let item2 = TemplateItemEntity(
            id: "2",
            title: "UIKit Guide",
            summary: "Traditional iOS development",
            creator: "Developer",
            createdDate: Date()
        )

        context.insert(item1)
        context.insert(item2)
        try context.save()

        // When
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>(
            predicate: #Predicate { item in
                item.title.localizedStandardContains("SwiftUI")
                    || item.summary.localizedStandardContains("SwiftUI")
            }
        )
        let items = try context.fetch(fetchDescriptor)

        // Then
        #expect(items.count == 1)
        #expect(items.first?.title == "SwiftUI Tutorial")
    }

    // MARK: - Conversion Tests

    @Test("Convert from TemplateItem to Entity")
    func convertFromTemplateItem() throws {
        // Given
        let templateItem = TemplateItem(
            id: "test-1",
            title: "Original Item",
            summary: "Original summary",
            creator: "Author",
            createdDate: Date(),
            categories: ["Test"],
            primaryCategory: "Test",
            hasAttachment: false,
            attachmentURL: nil
        )

        // When
        let entity = TemplateItemEntity(from: templateItem)
        context.insert(entity)
        try context.save()

        // Then
        #expect(entity.id == templateItem.id)
        #expect(entity.title == templateItem.title)
        #expect(entity.summary == templateItem.summary)
    }

    @Test("Convert from Entity to TemplateItem")
    func convertToTemplateItem() throws {
        // Given
        let entity = TemplateItemEntity(
            id: "test-1",
            title: "Entity Item",
            summary: "Entity summary",
            creator: "Author",
            createdDate: Date(),
            categories: ["Test"],
            primaryCategory: "Test"
        )

        context.insert(entity)
        try context.save()

        // When
        let templateItem = entity.toTemplateItem()

        // Then
        #expect(templateItem.id == entity.id)
        #expect(templateItem.title == entity.title)
        #expect(templateItem.summary == entity.summary)
    }

    // MARK: - Batch Operations

    @Test("Batch insert multiple items")
    func batchInsert() throws {
        // Given
        let items = (0..<100).map { index in
            TemplateItemEntity(
                id: "test-\(index)",
                title: "Item \(index)",
                summary: "Summary \(index)",
                creator: "Author \(index)",
                createdDate: Date()
            )
        }

        // When
        let startTime = Date()

        items.forEach { context.insert($0) }
        try context.save()

        let duration = Date().timeIntervalSince(startTime)

        // Then
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>()
        let fetchedItems = try context.fetch(fetchDescriptor)

        #expect(fetchedItems.count == 100)
        print("Batch insert of 100 items took: \(duration) seconds")
    }

    @Test("Batch delete all items")
    func batchDelete() throws {
        // Given
        let items = (0..<50).map { index in
            TemplateItemEntity(
                id: "test-\(index)",
                title: "Item \(index)",
                summary: "Summary \(index)",
                creator: "Author",
                createdDate: Date()
            )
        }

        items.forEach { context.insert($0) }
        try context.save()

        // When
        try context.deleteAll(TemplateItemEntity.self)

        // Then
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>()
        let remainingItems = try context.fetch(fetchDescriptor)

        #expect(remainingItems.count == 0)
    }

    // MARK: - Helper Tests

    @Test("Context helper: fetch all items")
    func contextHelperFetchAll() throws {
        // Given
        let items = (0..<5).map { index in
            TemplateItemEntity(
                id: "test-\(index)",
                title: "Item \(index)",
                summary: "Summary \(index)",
                creator: "Author",
                createdDate: Date()
            )
        }

        items.forEach { context.insert($0) }
        try context.save()

        // When
        let fetchedItems = try context.fetchAll(TemplateItemEntity.self)

        // Then
        #expect(fetchedItems.count == 5)
    }

    @Test("Context helper: count items")
    func contextHelperCount() throws {
        // Given
        let items = (0..<10).map { index in
            TemplateItemEntity(
                id: "test-\(index)",
                title: "Item \(index)",
                summary: "Summary \(index)",
                creator: "Author",
                createdDate: Date()
            )
        }

        items.forEach { context.insert($0) }
        try context.save()

        // When
        let count = try context.count(TemplateItemEntity.self)

        // Then
        #expect(count == 10)
    }

    @Test("Context helper: save if needed")
    func contextHelperSaveIfNeeded() throws {
        // Given
        let item = TemplateItemEntity(
            id: "test-1",
            title: "Test",
            summary: "Summary",
            creator: "Author",
            createdDate: Date()
        )

        // When
        context.insert(item)
        #expect(context.hasChanges == true)

        try context.saveIfNeeded()

        // Then
        #expect(context.hasChanges == false)
    }

    // MARK: - Performance Tests

    @Test("Query performance with 1000 items", .timeLimit(.minutes(1)))
    func queryPerformance() throws {
        // Given - Insert 1000 items
        let items = (0..<1000).map { index in
            TemplateItemEntity(
                id: "perf-\(index)",
                title: "Performance Item \(index)",
                summary: "Testing query performance",
                creator: "Author \(index % 10)",
                createdDate: Date(),
                primaryCategory: ["Tech", "Science", "Health"][index % 3]
            )
        }

        items.forEach { context.insert($0) }
        try context.save()

        // When - Test filtered query
        let fetchDescriptor = FetchDescriptor<TemplateItemEntity>(
            predicate: #Predicate { $0.primaryCategory == "Tech" }
        )

        let techItems = try context.fetch(fetchDescriptor)

        // Then
        #expect(techItems.count > 0)
        #expect(techItems.allSatisfy { $0.primaryCategory == "Tech" })
    }
}
