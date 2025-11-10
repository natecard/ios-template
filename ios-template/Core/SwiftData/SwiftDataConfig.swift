//
//  SwiftDataConfig.swift
//  ios-template
//
//  Configuration helpers for SwiftData ModelContainer.
//

import Foundation
import SwiftData

/// SwiftData configuration utilities
///
/// Provides helpers for creating ModelContainers for both production and testing.
///
/// Usage in your app:
/// ```swift
/// @main
/// struct YourApp: App {
///     let container: ModelContainer
///
///     init() {
///         do {
///             container = try SwiftDataConfig.productionContainer()
///         } catch {
///             fatalError("Failed to create ModelContainer: \(error)")
///         }
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///         }
///         .modelContainer(container)
///     }
/// }
/// ```
public enum SwiftDataConfig {

    // MARK: - Production Container

    /// Creates a persistent ModelContainer for production use
    ///
    /// Data is stored in the app's Application Support directory and persists across launches.
    ///
    /// - Returns: Configured ModelContainer
    /// - Throws: Error if container creation fails
    public static func productionContainer() throws -> ModelContainer {
        let schema = Schema([
            TemplateItemEntity.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    // MARK: - In-Memory Container (Testing)

    /// Creates an in-memory ModelContainer for testing
    ///
    /// Data exists only in memory and is not persisted. Perfect for unit tests.
    ///
    /// Example usage in tests:
    /// ```swift
    /// func testItemCreation() throws {
    ///     let container = try SwiftDataConfig.inMemoryContainer()
    ///     let context = ModelContext(container)
    ///
    ///     let item = TemplateItemEntity(
    ///         id: "test-1",
    ///         title: "Test Item",
    ///         summary: "Test summary",
    ///         creator: "Test Author",
    ///         createdDate: Date()
    ///     )
    ///
    ///     context.insert(item)
    ///     try context.save()
    ///
    ///     let fetchDescriptor = FetchDescriptor<TemplateItemEntity>()
    ///     let items = try context.fetch(fetchDescriptor)
    ///     XCTAssertEqual(items.count, 1)
    /// }
    /// ```
    ///
    /// - Returns: In-memory ModelContainer
    /// - Throws: Error if container creation fails
    public static func inMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            TemplateItemEntity.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    // MARK: - Custom Container

    /// Creates a ModelContainer with custom configuration
    ///
    /// Use this when you need more control over the container setup.
    ///
    /// - Parameters:
    ///   - inMemory: Whether to store data in memory only
    ///   - autosaveEnabled: Whether to enable automatic saving
    ///   - cloudKitEnabled: Whether to enable CloudKit sync (requires proper entitlements)
    /// - Returns: Configured ModelContainer
    /// - Throws: Error if container creation fails
    public static func customContainer(
        inMemory: Bool = false,
        autosaveEnabled: Bool = true,
        cloudKitEnabled: Bool = false
    ) throws -> ModelContainer {
        let schema = Schema([
            TemplateItemEntity.self
        ])

        var configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        // Note: CloudKit configuration requires proper entitlements and setup
        // See Apple's documentation for CloudKit + SwiftData integration
        if cloudKitEnabled {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: inMemory,
                cloudKitDatabase: .automatic
            )
        }

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}

// MARK: - ModelContext Helpers

extension ModelContext {

    /// Save changes if there are any
    ///
    /// - Throws: Error if save fails
    public func saveIfNeeded() throws {
        if hasChanges {
            try save()
        }
    }

    /// Fetch all items of a given type
    ///
    /// - Parameter type: The model type to fetch
    /// - Returns: Array of fetched items
    /// - Throws: Error if fetch fails
    public func fetchAll<T: PersistentModel>(_ type: T.Type) throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try fetch(descriptor)
    }

    /// Count items of a given type
    ///
    /// - Parameter type: The model type to count
    /// - Returns: Number of items
    /// - Throws: Error if fetch fails
    public func count<T: PersistentModel>(_ type: T.Type) throws -> Int {
        let descriptor = FetchDescriptor<T>()
        return try fetchCount(descriptor)
    }

    /// Delete all items of a given type
    ///
    /// - Parameter type: The model type to delete
    /// - Throws: Error if delete or save fails
    public func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let items = try fetchAll(type)
        items.forEach { delete($0) }
        try save()
    }
}
