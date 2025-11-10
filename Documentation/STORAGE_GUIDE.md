# Storage & Persistence Guide

This guide explains the template's persistence architecture and helps you choose the right storage solution for your needs.

## Overview

The template provides two complementary persistence options:

1. **JSON Persistence** (included by default) - Simple, lightweight file-based storage
2. **SwiftData** (optional) - Apple's modern data persistence framework

You can use one, the other, or **both together** depending on your app's requirements.

---

## JSON vs SwiftData Comparison

| Feature | JSON Persistence | SwiftData |
|---------|-----------------|-----------|
| **Use Case** | User preferences, favorites, collections | User-created content, offline-first apps |
| **Setup Complexity** | Minimal (already configured) | Moderate (requires ModelContainer setup) |
| **Data Size** | Small datasets (< 100 items) | Any size (optimized for large datasets) |
| **Query Performance** | Linear search in Swift | Indexed SQL queries |
| **Relationships** | Manual (references by ID) | Built-in (one-to-many, many-to-many) |
| **iCloud Sync** | Manual implementation required | Built-in CloudKit support |
| **Data Format** | Human-readable JSON files | Binary SQLite database |
| **Migration** | Manual (parse old/new JSON) | Automatic (with schema versioning) |
| **Testing** | Simple (mock files) | Built-in (in-memory containers) |
| **Memory Footprint** | All data loaded into memory | Lazy loading, faulting |
| **Concurrency** | Actor-based (manual) | Built-in with `ModelActor` |
| **Debugging** | Easy (view JSON files directly) | Requires database tools |
| **Best For** | Settings, flags, small lists | Notes, tasks, documents, media catalogs |

---

## Architecture Patterns

### Pattern 1: JSON Only (Simple Apps)

Use when your app:
- Fetches most data from an API
- Only needs to store user preferences
- Has minimal local data requirements

```swift
@main
struct SimpleApp: App {
    @State private var dataManager: ItemDataManager
    @State private var purchaseManager = PurchaseManager()
    
    init() {
        do {
            let persistence = try JSONPersistenceService()
            _dataManager = State(initialValue: ItemDataManager(
                persistenceService: persistence
            ))
        } catch {
            fatalError("Failed to initialize: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataManager)
                .environment(purchaseManager)
                .onAppear {
                    purchaseManager.start()
                }
        }
    }
}
```

**What's stored in JSON:**
- Favorite items (references by ID)
- User-created collections
- App preferences

---

### Pattern 2: SwiftData Only (Offline-First Apps)

Use when your app:
- Creates and manages local content
- Needs complex queries and relationships
- Works primarily offline

```swift
import SwiftData

@main
struct OfflineApp: App {
    let container: ModelContainer
    @State private var purchaseManager = PurchaseManager()
    
    init() {
        do {
            container = try SwiftDataConfig.productionContainer()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseManager)
                .onAppear {
                    purchaseManager.start()
                }
        }
        .modelContainer(container)
    }
}
```

**What's stored in SwiftData:**
- User-created items (notes, tasks, documents)
- Item relationships and hierarchies
- Metadata and tags

---

### Pattern 3: Hybrid (Recommended for Complex Apps)

Use both JSON and SwiftData when your app:
- Has user-created content AND API-fetched data
- Needs offline functionality for some features
- Wants simple storage for preferences

```swift
import SwiftData

@main
struct HybridApp: App {
    let swiftDataContainer: ModelContainer
    @State private var dataManager: ItemDataManager
    @State private var purchaseManager = PurchaseManager()
    
    init() {
        do {
            // SwiftData for user-created content
            swiftDataContainer = try SwiftDataConfig.productionContainer()
            
            // JSON for favorites and collections (API item references)
            let jsonPersistence = try JSONPersistenceService()
            _dataManager = State(initialValue: ItemDataManager(
                persistenceService: jsonPersistence
            ))
        } catch {
            fatalError("Failed to initialize: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataManager)
                .environment(purchaseManager)
                .onAppear {
                    purchaseManager.start()
                }
        }
        .modelContainer(swiftDataContainer)
    }
}
```

**Division of responsibility:**

| Data Type | Storage | Why |
|-----------|---------|-----|
| API-fetched items | In-memory (from repository) | Fresh data on each fetch |
| Favorites (API items) | JSON | Simple list of IDs, small size |
| Collections (API items) | JSON | User preferences, easy to export |
| User's notes/annotations | SwiftData | Rich content, searchable |
| User's custom tasks | SwiftData | Relationships, offline access |
| App settings | JSON or UserDefaults | Simple key-value pairs |

---

## Performance Guidelines

### JSON Persistence

**Strengths:**
- ✅ Fast for small datasets (< 100 items)
- ✅ No setup overhead
- ✅ Predictable performance
- ✅ Easy debugging

**Limitations:**
- ⚠️ Entire file loaded into memory
- ⚠️ Write requires full file rewrite
- ⚠️ No indexing or optimization
- ⚠️ Linear search O(n) complexity

**Optimization tips:**
```swift
// Good: Small, focused data
let favorites = try await persistence.loadFavorites() // ~50 items

// Bad: Large datasets
let allItems = try await persistence.loadFavorites() // 10,000+ items ❌
```

---

### SwiftData

**Strengths:**
- ✅ Optimized for large datasets
- ✅ Lazy loading (faulting)
- ✅ Indexed queries O(log n)
- ✅ Automatic memory management
- ✅ Background context support

**Optimization strategies:**

#### 1. Use Indexed Attributes
```swift
@Model
final class Item {
    @Attribute(.indexed) var category: String  // ✅ Fast filtering
    @Attribute(.indexed) var createdDate: Date  // ✅ Fast sorting
    var notes: String  // Not indexed - rarely queried
}
```

#### 2. Batch Operations
```swift
// Good: Batch insert
let items = (0..<1000).map { TemplateItemEntity(...) }
items.forEach { modelContext.insert($0) }
try modelContext.save()  // Single transaction

// Bad: Individual saves
for item in items {
    modelContext.insert(item)
    try modelContext.save()  // 1000 transactions ❌
}
```

#### 3. Use Predicates Efficiently
```swift
// Good: Database-level filtering
@Query(
    filter: #Predicate<Item> { $0.category == "Tech" }
)
var techItems: [Item]

// Bad: In-memory filtering
@Query var allItems: [Item]
var techItems: [Item] {
    allItems.filter { $0.category == "Tech" }  // ❌ Loads everything
}
```

#### 4. Limit Fetch Results
```swift
var descriptor = FetchDescriptor<Item>(
    predicate: #Predicate { $0.category == "Tech" },
    sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
)
descriptor.fetchLimit = 50  // Only fetch what's needed
let items = try modelContext.fetch(descriptor)
```

#### 5. Use Background Contexts for Heavy Operations
```swift
Task.detached {
    let backgroundContext = ModelContext(container)
    
    // Heavy import/export operations
    for data in largeDataset {
        let item = TemplateItemEntity(from: data)
        backgroundContext.insert(item)
    }
    
    try backgroundContext.save()
}
```

---

## Storage Locations

### JSON Files

Located in Application Support directory:
```
~/Library/Application Support/ios-template/
├── favorites.json
└── collections.json
```

Access programmatically:
```swift
let appSupport = FileManager.default.urls(
    for: .applicationSupportDirectory,
    in: .userDomainMask
).first!

let directory = appSupport.appendingPathComponent("ios-template")
```

### SwiftData Files

Located in Application Support (managed automatically):
```
~/Library/Application Support/ios-template/
└── default.store  // SQLite database + supporting files
```

---

## Data Migration Strategies

### JSON Migration

When changing JSON structure:

```swift
actor JSONPersistenceService {
    private let version = 2  // Increment on changes
    
    func loadFavorites() async throws -> [Item] {
        guard let data = try? Data(contentsOf: favoritesURL) else {
            return []
        }
        
        let decoder = JSONDecoder()
        
        // Try current version
        if let items = try? decoder.decode([Item].self, from: data) {
            return items
        }
        
        // Fallback to v1 format
        if let oldItems = try? decoder.decode([ItemV1].self, from: data) {
            return oldItems.map { $0.toCurrentVersion() }
        }
        
        return []
    }
}
```

### SwiftData Migration

SwiftData handles most migrations automatically:

```swift
// V1 Schema
@Model
final class Item {
    var title: String
}

// V2 Schema (automatic migration)
@Model
final class Item {
    var title: String
    var subtitle: String = ""  // New property with default
}
```

For complex migrations, use `VersionedSchema`:
```swift
enum ItemSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    @Model
    final class Item {
        var title: String
    }
}

enum ItemSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    @Model
    final class Item {
        var title: String
        var category: String
    }
}
```

---

## Testing Strategies

### Testing JSON Persistence

```swift
func testFavorites() async throws {
    let persistence = try JSONPersistenceService()
    
    let item = TemplateItem(id: "1", title: "Test", ...)
    try await persistence.saveFavorites([item])
    
    let loaded = try await persistence.loadFavorites()
    XCTAssertEqual(loaded.count, 1)
    XCTAssertEqual(loaded.first?.id, "1")
}
```

### Testing SwiftData

```swift
func testSwiftData() throws {
    // Use in-memory container for tests
    let container = try SwiftDataConfig.inMemoryContainer()
    let context = ModelContext(container)
    
    let item = TemplateItemEntity(
        id: "1",
        title: "Test",
        summary: "Test summary",
        creator: "Author",
        createdDate: Date()
    )
    
    context.insert(item)
    try context.save()
    
    let fetchDescriptor = FetchDescriptor<TemplateItemEntity>()
    let items = try context.fetch(fetchDescriptor)
    XCTAssertEqual(items.count, 1)
}
```

See `ios-templateTests/SwiftDataTests.swift` for complete examples.

---

## Decision Matrix

Choose your storage based on these questions:

### Use JSON if you answer YES to:
- [ ] My data is small (< 100 items)
- [ ] I mostly fetch from APIs
- [ ] I only need favorites/collections
- [ ] I want minimal setup
- [ ] I need human-readable files
- [ ] I don't need complex queries

### Use SwiftData if you answer YES to:
- [ ] Users create their own content
- [ ] I need offline-first functionality
- [ ] I have complex data relationships
- [ ] I need to search large datasets
- [ ] I want iCloud sync
- [ ] I need background processing

### Use Both if you answer YES to:
- [ ] I have API data AND user content
- [ ] Some features work offline, others online
- [ ] I want simple preferences + complex data
- [ ] I need flexibility for future features

---

## Common Patterns

### Example: Note-Taking App

```swift
// User's notes → SwiftData
@Query(sort: \.createdDate, order: .reverse)
var notes: [NoteEntity]

// Favorite templates (from API) → JSON
@Environment(ItemDataManager.self) var dataManager
var favoriteTemplates: [TemplateItem] {
    dataManager.favoriteItems
}
```

### Example: Task Manager

```swift
// User's tasks → SwiftData
@Query(
    filter: #Predicate<TaskEntity> { !$0.isCompleted },
    sort: \.dueDate
)
var pendingTasks: [TaskEntity]

// Task collections/categories → JSON
@Environment(ItemDataManager.self) var dataManager
var taskCollections: [TemplateItemCollection] {
    dataManager.userCollections
}
```

### Example: Recipe App

```swift
// Recipes from API → In-memory (ItemRepository)
@State private var recipes: [Recipe] = []

// User's favorites → JSON (just IDs)
@Environment(ItemDataManager.self) var dataManager

// User's custom recipes → SwiftData
@Query var customRecipes: [CustomRecipeEntity]
```

---

## Best Practices

### 1. Separate Concerns
- **ItemRepository**: Fetch from network/API
- **JSONPersistence**: User preferences and simple lists
- **SwiftData**: User-created content

### 2. Choose Wisely
- Don't use SwiftData for everything
- Don't store API responses in SwiftData
- Use the simplest solution that works

### 3. Plan for Growth
- Start with JSON for simplicity
- Add SwiftData when you need it
- Design for easy migration

### 4. Test Both Layers
- Unit test JSON serialization
- Use in-memory containers for SwiftData tests
- Integration test the combination

### 5. Monitor Performance
- Profile with Instruments
- Watch for memory leaks
- Optimize queries as needed

---

## Resources

- [JSON Persistence Implementation](../ios-template/Repositories/Implementations/JSONPersistenceService.swift)
- [SwiftData Implementation](../ios-template/Core/SwiftData/)
- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Integration Guide](INTEGRATION_GUIDE.md)
- [Protocol Guide](PROTOCOL_GUIDE.md)

---

## Next Steps

1. Review your app requirements
2. Choose JSON, SwiftData, or both
3. Read [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for implementation
4. See examples in [SwiftData README](../ios-template/Core/SwiftData/README.md)
5. Check test examples in `ios-templateTests/`
