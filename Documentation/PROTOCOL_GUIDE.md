# Protocol Guide

This guide explains how to implement the generic protocols included in this template.

## Overview

The template uses protocol-oriented design with associated types to support any domain model. The core protocols are:

- **GenericItem**: Your content type (items, products, media, etc.)
- **GenericCollection**: Groups of items
- **GenericDataManager**: Manages items and favorites
- **PersistenceServiceProtocol**: Saves/loads data
- **FileStorageProviderProtocol**: Manages file attachments

---

## GenericItem Protocol

### Required Properties

```swift
public protocol GenericItem: Identifiable, Codable, Equatable, Sendable where ID == String {
    var id: String { get }
    var title: String { get }
    var summary: String { get }
    var creator: String { get }
    var createdDate: Date { get }
    var categories: [String] { get }
    var primaryCategory: String { get }
    var hasAttachment: Bool { get }
    var attachmentURL: URL? { get }
    var metadata: [ItemMetadataEntry] { get }
}
```

### Implementation Examples

#### Simple Implementation

```swift
struct BlogPost: GenericItem {
    let id: String
    let title: String
    let content: String
    let author: String
    let publishDate: Date
    let tags: [String]
    
    // Protocol conformance
    var summary: String { String(content.prefix(200)) }
    var creator: String { author }
    var createdDate: Date { publishDate }
    var categories: [String] { tags }
    var primaryCategory: String { tags.first ?? "General" }
    var hasAttachment: Bool { false }
    var attachmentURL: URL? { nil }
    // metadata uses default implementation (empty array)
}
```

#### Rich Implementation with Metadata

```swift
struct Product: GenericItem {
    let id: String
    let name: String
    let description: String
    let manufacturer: String
    let releaseDate: Date
    let productCategories: [String]
    let price: Decimal
    let currency: String
    let imageURL: URL?
    let inStock: Bool
    
    var title: String { name }
    var summary: String { description }
    var creator: String { manufacturer }
    var createdDate: Date { releaseDate }
    var categories: [String] { productCategories }
    var primaryCategory: String { productCategories.first ?? "Uncategorized" }
    var hasAttachment: Bool { imageURL != nil }
    var attachmentURL: URL? { imageURL }
    
    var metadata: [ItemMetadataEntry] {
        var entries: [ItemMetadataEntry] = []
        
        // Price badge
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        if let priceString = formatter.string(from: price as NSDecimalNumber) {
            entries.append(ItemMetadataEntry(
                key: "price",
                value: priceString,
                presentation: .badge
            ))
        }
        
        // Stock status
        entries.append(ItemMetadataEntry(
            key: "stock",
            value: inStock ? "In Stock" : "Out of Stock",
            presentation: .inline
        ))
        
        // Categories as tags
        entries.append(contentsOf: productCategories.map {
            ItemMetadataEntry(key: "category", value: $0, presentation: .tag)
        })
        
        return entries
    }
}
```

#### Media Implementation

```swift
struct Podcast: GenericItem {
    let id: String
    let episodeTitle: String
    let showDescription: String
    let host: String
    let publishedAt: Date
    let genres: [String]
    let audioURL: URL?
    let duration: TimeInterval
    
    var title: String { episodeTitle }
    var summary: String { showDescription }
    var creator: String { host }
    var createdDate: Date { publishedAt }
    var categories: [String] { genres }
    var primaryCategory: String { genres.first ?? "Podcast" }
    var hasAttachment: Bool { audioURL != nil }
    var attachmentURL: URL? { audioURL }
    
    var metadata: [ItemMetadataEntry] {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        let durationString = formatter.string(from: duration) ?? ""
        
        return [
            ItemMetadataEntry(key: "duration", value: durationString, presentation: .inline)
        ] + genres.map {
            ItemMetadataEntry(key: "genre", value: $0, presentation: .tag)
        }
    }
}
```

---

## GenericCollection Protocol

### Implementation

```swift
@Observable
class TodoList: GenericCollection {
    typealias Item = TodoItem
    
    var id = UUID()
    var items: [TodoItem]
    var heading: String?
    var color: Color?  // Custom property
    
    init(items: [TodoItem] = [], heading: String? = nil, color: Color? = nil) {
        self.items = items
        self.heading = heading
        self.color = color
    }
}

// Required for Sendable conformance
extension TodoList: @unchecked Sendable {}

// Custom methods
extension TodoList {
    var completedItems: [TodoItem] {
        items.filter { $0.isCompleted }
    }
    
    var pendingItems: [TodoItem] {
        items.filter { !$0.isCompleted }
    }
}
```

---

## GenericDataManager Protocol

### Full Implementation

```swift
@MainActor
@Observable
class ItemManager: GenericDataManager {
    typealias Item = Item
    typealias Collection = ItemCollection
    
    var items: [Item] = []
    var favoriteItems: [Item] = []
    var userCollections: [ItemCollection] = []
    
    // Additional properties
    var isLoading = false
    var errorMessage: String?
    
    private let persistenceService: any PersistenceServiceProtocol
    private let networkService: ItemNetworkService
    
    init(
        persistenceService: any PersistenceServiceProtocol,
        networkService: ItemNetworkService
    ) {
        self.persistenceService = persistenceService
        self.networkService = networkService
    }
    
    // MARK: - Protocol Requirements
    
    func isFavorite(_ item: Item) -> Bool {
        favoriteItems.contains(where: { $0.id == item.id })
    }
    
    func toggleFavorite(_ item: Item) {
        if isFavorite(item) {
            removeFavorite(item)
        } else {
            addFavorite(item)
        }
    }
    
    func addFavorite(_ item: Item) {
        guard !isFavorite(item) else { return }
        favoriteItems.append(item)
        Task {
            try? await persistenceService.saveFavorites(favoriteItems)
        }
    }
    
    func removeFavorite(_ item: Item) {
        favoriteItems.removeAll(where: { $0.id == item.id })
        Task {
            try? await persistenceService.saveFavorites(favoriteItems)
        }
    }
    
    // MARK: - Additional Methods
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load from persistence
            favoriteItems = try await persistenceService.loadFavorites()
            userCollections = try await persistenceService.loadCollections()
            
            // Load from network
            items = try await networkService.fetchItems()
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func addToCollection(_ item: Item, collection: ItemCollection) {
        guard let index = userCollections.firstIndex(where: { $0.id == collection.id }) else {
            return
        }
        userCollections[index].items.append(item)
        Task {
            try? await persistenceService.saveCollections(userCollections)
        }
    }
    
    func createCollection(heading: String, items: [Item] = []) {
        let collection = ItemCollection(items: items, heading: heading)
        userCollections.append(collection)
        Task {
            try? await persistenceService.saveCollections(userCollections)
        }
    }
}
```

---

## PersistenceServiceProtocol

### JSON File Implementation

```swift
actor JSONPersistenceService<Item: GenericItem, Collection: GenericCollection>: PersistenceServiceProtocol 
    where Collection.Item == Item {
    
    private let favoritesURL: URL
    private let collectionsURL: URL
    
    init(appName: String) throws {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        
        let directory = appSupport.appendingPathComponent(appName)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        
        favoritesURL = directory.appendingPathComponent("favorites.json")
        collectionsURL = directory.appendingPathComponent("collections.json")
    }
    
    func saveFavorites(_ items: [Item]) async throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: favoritesURL, options: .atomic)
    }
    
    func loadFavorites() async throws -> [Item] {
        guard FileManager.default.fileExists(atPath: favoritesURL.path) else {
            return []
        }
        let data = try Data(contentsOf: favoritesURL)
        return try JSONDecoder().decode([Item].self, from: data)
    }
    
    func saveCollections(_ collections: [Collection]) async throws {
        let data = try JSONEncoder().encode(collections)
        try data.write(to: collectionsURL, options: .atomic)
    }
    
    func loadCollections() async throws -> [Collection] {
        guard FileManager.default.fileExists(atPath: collectionsURL.path) else {
            return []
        }
        let data = try Data(contentsOf: collectionsURL)
        return try JSONDecoder().decode([Collection].self, from: data)
    }
    
    func clearAllData() async throws {
        try? FileManager.default.removeItem(at: favoritesURL)
        try? FileManager.default.removeItem(at: collectionsURL)
    }
}
```

### Core Data Implementation (Sketch)

```swift
actor CoreDataPersistenceService<Item: GenericItem, Collection: GenericCollection>: PersistenceServiceProtocol 
    where Collection.Item == Item {
    
    private let container: NSPersistentContainer
    
    init(containerName: String) {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }
    
    func saveFavorites(_ items: [Item]) async throws {
        // Convert items to Core Data entities
        // Save context
    }
    
    // Implement other methods...
}
```

---

## FileStorageProviderProtocol

### Implementation Example

```swift
actor LocalFileStorageProvider<Item: GenericItem>: FileStorageProviderProtocol {
    
    private let baseURL: URL
    
    init() throws {
        let docs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        baseURL = docs.appendingPathComponent("Files")
        try FileManager.default.createDirectory(
            at: baseURL,
            withIntermediateDirectories: true
        )
    }
    
    func store(
        data: Data,
        for item: Item,
        scope: StorageScope,
        fileExtension: FileExtension
    ) async throws -> URL {
        let filename = "\(item.id)\(fileExtension.withDot)"
        let fileURL = baseURL.appendingPathComponent(filename)
        try data.write(to: fileURL)
        return fileURL
    }
    
    func url(
        for item: Item,
        scope: StorageScope,
        fileExtension: FileExtension
    ) async -> URL? {
        let filename = "\(item.id)\(fileExtension.withDot)"
        let fileURL = baseURL.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func exists(
        for item: Item,
        scope: StorageScope,
        fileExtension: FileExtension
    ) async -> Bool {
        await url(for: item, scope: scope, fileExtension: fileExtension) != nil
    }
    
    func listAll(
        scope: StorageScope,
        fileExtension: FileExtension?
    ) async -> [URL] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: baseURL,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        
        if let fileExtension = fileExtension {
            return urls.filter { $0.pathExtension == fileExtension.rawValue }
        }
        return urls
    }
    
    func deleteAllFiles(
        scope: StorageScope,
        fileExtension: FileExtension?
    ) async throws {
        let urls = await listAll(scope: scope, fileExtension: fileExtension)
        for url in urls {
            try FileManager.default.removeItem(at: url)
        }
    }
}
```

---

## Usage Patterns

### Dependency Injection

```swift
@main
struct YourApp: App {
    let persistence: JSONPersistenceService<Item, ItemCollection>
    let storage: LocalFileStorageProvider<Item>
    let dataManager: ItemManager
    let purchaseManager = PurchaseManager()
    
    init() {
        do {
            persistence = try JSONPersistenceService(appName: "YourApp")
            storage = try LocalFileStorageProvider()
            dataManager = ItemManager(
                persistenceService: persistence,
                networkService: ItemNetworkService()
            )
        } catch {
            fatalError("Failed to initialize services: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataManager)
                .environment(purchaseManager)
                .task {
                    await dataManager.loadData()
                    purchaseManager.start()
                }
        }
    }
}
```

### Type Erasure for Testing

```swift
class MockPersistence<Item: GenericItem, Collection: GenericCollection>: PersistenceServiceProtocol 
    where Collection.Item == Item {
    
    var savedFavorites: [Item] = []
    var savedCollections: [Collection] = []
    
    func saveFavorites(_ items: [Item]) async throws {
        savedFavorites = items
    }
    
    func loadFavorites() async throws -> [Item] {
        savedFavorites
    }
    
    func saveCollections(_ collections: [Collection]) async throws {
        savedCollections = collections
    }
    
    func loadCollections() async throws -> [Collection] {
        savedCollections
    }
    
    func clearAllData() async throws {
        savedFavorites = []
        savedCollections = []
    }
}
```

---

## Best Practices

1. **Use Associated Types** for maximum flexibility
2. **Make Types Sendable** for Swift concurrency support
3. **Provide Default Implementations** where possible
4. **Use @unchecked Sendable** carefully (only when thread-safe)
5. **Document Custom Properties** in your conforming types
6. **Test Protocol Conformance** with unit tests

---

## Next Steps

- See [Integration Guide](INTEGRATION_GUIDE.md) for setup
- See [Customization Guide](CUSTOMIZATION_GUIDE.md) for theming
