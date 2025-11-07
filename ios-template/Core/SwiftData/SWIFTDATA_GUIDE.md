# SwiftData Integration (Optional)

This directory contains SwiftData implementation for **optional** local data storage. SwiftData is Apple's modern framework for data persistence, built on Core Data.

## When to Use SwiftData

SwiftData is best suited for apps that need:

- **User-created content**: Notes, tasks, journal entries, drawings
- **Offline-first functionality**: Apps that work without network connection
- **Complex data relationships**: Related entities with one-to-many or many-to-many relationships
- **Advanced querying**: Filtering, sorting, and searching large datasets efficiently
- **CloudKit sync**: Built-in iCloud synchronization support

## When to Use JSON Persistence Instead

Stick with `JSONPersistenceService` (already included in the template) when:

- Your app primarily fetches data from an API
- You only need to store simple user preferences (favorites, collections)
- Your dataset is small (< 100 items)
- You want minimal setup and dependencies

**See [STORAGE_GUIDE.md](../../Documentation/STORAGE_GUIDE.md) for detailed comparison.**

## What's Included

### 1. TemplateItemEntity.swift
SwiftData model (`@Model`) that demonstrates:
- Basic properties with type safety
- Indexed attributes for performance
- Computed properties for URL transformation
- Conversion to/from `TemplateItem`
- Query helpers and predicates

### 2. SwiftDataConfig.swift
Configuration utilities providing:
- `productionContainer()` - Persistent storage for production
- `inMemoryContainer()` - In-memory storage for testing
- `customContainer()` - Flexible configuration options
- `ModelContext` extension helpers

## Quick Start

### 1. Set Up ModelContainer

In your app's main file:

```swift
import SwiftUI
import SwiftData

@main
struct YourApp: App {
    let container: ModelContainer
    
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
        }
        .modelContainer(container)
    }
}
```

### 2. Use @Query in Views

```swift
import SwiftUI
import SwiftData

struct ItemListView: View {
    @Query(sort: \.createdDate, order: .reverse) 
    private var items: [TemplateItemEntity]
    
    var body: some View {
        List(items) { item in
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Text(item.summary)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

### 3. Insert Data with ModelContext

```swift
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var summary = ""
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Summary", text: $summary)
            
            Button("Save") {
                let item = TemplateItemEntity(
                    id: UUID().uuidString,
                    title: title,
                    summary: summary,
                    creator: "Current User",
                    createdDate: Date()
                )
                
                modelContext.insert(item)
                try? modelContext.save()
            }
        }
    }
}
```

## Advanced Usage

### Filtering by Category

```swift
@Query(
    filter: #Predicate<TemplateItemEntity> { item in
        item.primaryCategory == "Technology"
    },
    sort: \.createdDate,
    order: .reverse
)
private var techItems: [TemplateItemEntity]
```

### Searching

```swift
struct SearchableItemList: View {
    @State private var searchText = ""
    
    @Query private var allItems: [TemplateItemEntity]
    
    var filteredItems: [TemplateItemEntity] {
        if searchText.isEmpty {
            return allItems
        }
        return allItems.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.summary.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(filteredItems) { item in
            // Item row
        }
        .searchable(text: $searchText)
    }
}
```

### Manual Fetching with Predicates

```swift
@Environment(\.modelContext) private var modelContext

func fetchRecentItems() throws -> [TemplateItemEntity] {
    let calendar = Calendar.current
    let lastWeek = calendar.date(byAdding: .day, value: -7, to: Date())!
    
    let descriptor = FetchDescriptor<TemplateItemEntity>(
        predicate: #Predicate { item in
            item.createdDate >= lastWeek
        },
        sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
    )
    
    return try modelContext.fetch(descriptor)
}
```

### Updating Items

```swift
func updateItem(_ item: TemplateItemEntity, newTitle: String) {
    item.title = newTitle
    // SwiftData automatically tracks changes
    try? modelContext.save()
}
```

### Deleting Items

```swift
func deleteItem(_ item: TemplateItemEntity) {
    modelContext.delete(item)
    try? modelContext.save()
}
```

## Combining with JSON Persistence

You can use **both** SwiftData and JSON in the same app:

- **SwiftData**: User-created items (notes, tasks, custom content)
- **JSON**: User preferences (favorites, collections, settings)

Example app structure:
```swift
@main
struct HybridApp: App {
    let swiftDataContainer: ModelContainer
    @State private var jsonPersistence: JSONPersistenceService
    @State private var dataManager: ItemDataManager
    
    init() {
        do {
            // SwiftData for user content
            swiftDataContainer = try SwiftDataConfig.productionContainer()
            
            // JSON for favorites/collections
            jsonPersistence = try JSONPersistenceService()
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
        }
        .modelContainer(swiftDataContainer)
    }
}
```

## Testing

See `ios-templateTests/SwiftDataTests.swift` for examples of:
- Using in-memory containers for unit tests
- Testing CRUD operations
- Testing queries and predicates
- Performance testing with large datasets

## Performance Tips

1. **Use `@Attribute(.indexed)`** for properties you filter or sort by frequently
2. **Batch operations** when inserting/updating many items
3. **Use predicates efficiently** - SwiftData optimizes them to SQL queries
4. **Avoid loading all data** - use `@Query` with predicates instead of filtering in Swift
5. **Save strategically** - SwiftData auto-saves, but you can call `save()` explicitly for critical operations

## Migration

SwiftData handles schema changes automatically in most cases. When you modify your models:

1. **Adding properties**: Works automatically with default values
2. **Removing properties**: Works automatically (data is discarded)
3. **Renaming properties**: Requires custom migration
4. **Changing types**: Requires custom migration

For complex migrations, see Apple's [SwiftData Migration Guide](https://developer.apple.com/documentation/swiftdata/migrating-your-app-to-swiftdata).

## CloudKit Sync

To enable iCloud sync:

1. Add CloudKit capability in Xcode
2. Configure container identifier
3. Use `cloudKitEnabled: true` when creating container:
   ```swift
   let container = try SwiftDataConfig.customContainer(cloudKitEnabled: true)
   ```

## Resources

- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [SwiftData WWDC Sessions](https://developer.apple.com/videos/swiftdata)
- [Model Macro Documentation](https://developer.apple.com/documentation/swiftdata/model())
- [Query Macro Documentation](https://developer.apple.com/documentation/swiftdata/query)

## Next Steps

- Review [STORAGE_GUIDE.md](../../Documentation/STORAGE_GUIDE.md) for architecture decisions
- See [INTEGRATION_GUIDE.md](../../Documentation/INTEGRATION_GUIDE.md) for full integration examples
- Check out the test examples in `ios-templateTests/SwiftDataTests.swift`
