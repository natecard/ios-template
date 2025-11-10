# Integration Guide

This guide walks you through integrating the template into your iOS/macOS application.

## Table of Contents

1. [Project Setup](#project-setup)
2. [Design System Integration](#design-system-integration)
3. [Protocol Implementation](#protocol-implementation)
4. [UI Components](#ui-components)
5. [Purchase System](#purchase-system)
6. [Testing](#testing)

---

## Project Setup

### Step 1: Add Template Files

1. Copy the `ios-template/` folder into your Xcode project
2. Ensure all files are added to your app target
3. Verify imports compile successfully

### Step 2: Configure Info.plist

Add the required keys for in-app purchases:

```xml
<key>IAPProductID</key>
<string>com.yourcompany.yourapp.full_unlock</string>

<key>IAPValidationURL</key>
<string>https://yourapi.com/validate</string>

<key>IAPValidationURLSandbox</key>
<string>https://yourapi.com/validate/sandbox</string>
```

---

## Design System Integration

### Basic Usage

The design system is automatically available after import:

```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        Text("Hello World")
            .font(DesignSystem.Typography.titleLarge)
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .designPadding(.md, .horizontal)
            .background(DesignSystem.Colors.surface)
            .designCornerRadius(DesignSystem.BorderRadius.lg)
            .designShadow(DesignSystem.Shadows.medium)
    }
}
```

### Motion Settings

Initialize motion settings in your app:

```swift
@main
struct YourApp: App {
    @State private var purchaseManager = PurchaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseManager)
                .onAppear {
                    purchaseManager.start()  // ⚠️ REQUIRED: Initializes StoreKit listeners
                }
        }
    }
}
```

> **⚠️ Important**: The `purchaseManager.start()` call is **required** in `.onAppear`. This initializes StoreKit transaction listeners for:
> - Purchase restoration on app launch
> - Transaction updates (refunds, renewals)
> - Subscription status changes
> 
> Without calling `start()`, purchases may complete but the app won't receive transaction updates.

### Customizing Colors

Override design system colors:

```swift
// In your app initialization or theme manager
extension DesignSystem.Colors {
    static var customPrimary: Color {
        #if os(iOS)
        return Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
                : UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        })
        #else
        return Color(nsColor: NSColor { appearance in
            appearance.name == .darkAqua
                ? NSColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
                : NSColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        })
        #endif
    }
}
```

---

## Protocol Implementation

### 1. Implement GenericItem

Define your content type:

```swift
struct Item: GenericItem {
    // Required properties
    let id: String
    let title: String
    let abstract: String
    let author: String
    let publishedDate: Date
    let category: String
    let tags: [String]
    let pdfURL: URL?
    
    // Protocol conformance
    var summary: String { abstract }
    var creator: String { author }
    var createdDate: Date { publishedDate }
    var categories: [String] { tags }
    var primaryCategory: String { category }
    var hasAttachment: Bool { pdfURL != nil }
    var attachmentURL: URL? { pdfURL }
    
    // Optional: rich metadata
    var metadata: [ItemMetadataEntry] {
        tags.map { ItemMetadataEntry(key: "tag", value: $0, presentation: .tag) }
    }
}

// Make it sendable for concurrency
extension Item: @unchecked Sendable {}
```

### 2. Implement GenericCollection

Create a collection type:

```swift
@Observable
class ItemCollection: GenericCollection {
    typealias Item = Item
    
    var id = UUID()
    var items: [Item]
    var heading: String?
    
    init(items: [Item] = [], heading: String? = nil) {
        self.items = items
        self.heading = heading
    }
}

extension ItemCollection: @unchecked Sendable {}
```

### 3. Implement Data Manager

Create a data manager conforming to `GenericDataManager`:

```swift
@MainActor
@Observable
class ItemDataManager: GenericDataManager {
    typealias Item = Item
    typealias Collection = ItemCollection
    
    var items: [Item] = []
    var favoriteItems: [Item] = []
    var userCollections: [ItemCollection] = []
    
    private let persistenceService: any PersistenceServiceProtocol
    
    init(persistenceService: any PersistenceServiceProtocol) {
        self.persistenceService = persistenceService
    }
    
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
}
```

### 4. Implement Persistence Service (Optional)

If you want to provide an implementation:

```swift
actor JSONPersistenceService: PersistenceServiceProtocol {
    typealias Item = Item
    typealias Collection = ItemCollection
    
    private let favoritesURL: URL
    private let collectionsURL: URL
    
    init() throws {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        
        let directory = appSupport.appendingPathComponent("YourApp")
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        
        favoritesURL = directory.appendingPathComponent("favorites.json")
        collectionsURL = directory.appendingPathComponent("collections.json")
    }
    
    func saveFavorites(_ items: [Item]) async throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: favoritesURL)
    }
    
    func loadFavorites() async throws -> [Item] {
        guard FileManager.default.fileExists(atPath: favoritesURL.path) else {
            return []
        }
        let data = try Data(contentsOf: favoritesURL)
        return try JSONDecoder().decode([Item].self, from: data)
    }
    
    func saveCollections(_ collections: [ItemCollection]) async throws {
        let data = try JSONEncoder().encode(collections)
        try data.write(to: collectionsURL)
    }
    
    func loadCollections() async throws -> [ItemCollection] {
        guard FileManager.default.fileExists(atPath: collectionsURL.path) else {
            return []
        }
        let data = try Data(contentsOf: collectionsURL)
        return try JSONDecoder().decode([ItemCollection].self, from: data)
    }
    
    func clearAllData() async throws {
        try? FileManager.default.removeItem(at: favoritesURL)
        try? FileManager.default.removeItem(at: collectionsURL)
    }
}
```

---

## UI Components

### Using Modern Item Cards

```swift
struct ItemListView: View {
    @State private var items: [Item] = []
    @Environment(ItemDataManager.self) private var dataManager
    @Environment(PurchaseManager.self) private var purchaseManager
    
    var body: some View {
        ModernItemListView(
            items: items,
            metadata: { item in
                ItemCardMetadata(
                    displayCategories: item.tags,
                    badgeText: item.category,
                    badgeColor: categoryColor(for: item.category),
                    attachmentLabel: "PDF",
                    attachmentIcon: "doc.fill"
                )
            },
            isLoading: items.isEmpty,
            emptyStateConfig: EmptyStateConfig(
                loadingMessage: "Loading items...",
                emptyTitle: "No Items",
                emptyMessage: "Start searching to discover items",
                emptyActionTitle: "Browse Categories",
                emptyAction: { /* Navigate to categories */ }
            ),
            onItemTap: { item in
                // Navigate to detail view
            },
            onFavorite: { item in
                dataManager.toggleFavorite(item)
            },
            onShare: { item in
                // Show share sheet
            }
        )
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Technology": return DesignSystem.Colors.primary
        case "Science": return DesignSystem.Colors.success
        case "Health": return DesignSystem.Colors.warning
        default: return DesignSystem.Colors.neutral
        }
    }
}
```

### Using Buttons

```swift
struct ActionBar: View {
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        HStack {
            SecondaryButton(
                title: "Cancel",
                action: onCancel
            )
            
            PrimaryButton(
                title: "Save",
                icon: "checkmark",
                action: onSave
            )
        }
    }
}
```

### Using Search

```swift
struct SearchView: View {
    @State private var searchText = ""
    @State private var suggestions = ["machine learning", "AI", "robotics"]
    
    var body: some View {
        ModernSearchBar(
            text: $searchText,
            placeholder: "Search items...",
            showSuggestions: !searchText.isEmpty,
            suggestions: suggestions,
            onSuggestionTap: { suggestion in
                performSearch(suggestion)
            },
            onSearch: {
                performSearch(searchText)
            }
        )
    }
    
    func performSearch(_ query: String) {
        // Implement search
    }
}
```

---

## Purchase System

### 1. Initialize Purchase Manager

In your app's main file:

```swift
@main
struct YourApp: App {
    @State private var purchaseManager = PurchaseManager()
    @State private var dataManager: ItemDataManager
    
    init() {
        let persistence = try! JSONPersistenceService()
        _dataManager = State(initialValue: ItemDataManager(persistenceService: persistence))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseManager)
                .environment(dataManager)
                .onAppear {
                    purchaseManager.start()
                }
        }
    }
}
```

### 2. Show Paywall

```swift
struct SettingsView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    
    var body: some View {
        List {
            Section("Premium Features") {
                Toggle("Cloud Sync", isOn: $cloudSyncEnabled)
                    .onChange(of: cloudSyncEnabled) { _, newValue in
                        if newValue && !purchaseManager.isFullAppUnlocked {
                            purchaseManager.presentPaywall(source: "cloud-sync-toggle")
                        }
                    }
            }
        }
        .sheet(isPresented: $purchaseManager.isPaywallPresented) {
            FullUnlockPaywallView()
        }
    }
}
```

### 3. Gate Features

```swift
struct PremiumFeatureView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    
    var body: some View {
        VStack {
            if purchaseManager.isFullAppUnlocked {
                PremiumContent()
            } else {
                LockedFeatureView {
                    purchaseManager.presentPaywall(source: "premium-feature")
                }
            }
        }
    }
}
```

---

## Advanced: SwiftData Integration (Optional)

The template includes optional SwiftData support for local persistence of user-created structured data.

### When to Use SwiftData

Consider SwiftData when you need:
- Complex queries (filtering, sorting, relationships)
- Offline-first architecture for user-created content
- Automatic schema migrations
- Relationships between data models

**Note**: SwiftData is **not** for caching API responses. Use `ItemRepository` in-memory caching for that.

### Quick Start

1. **Add ModelContainer to your App**:

```swift
import SwiftUI
import SwiftData

@main
struct YourApp: App {
    @State private var purchaseManager = PurchaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseManager)
                .modelContainer(SwiftDataConfig.productionContainer())
                .onAppear {
                    purchaseManager.start()
                }
        }
    }
}
```

2. **Query and insert data**:

```swift
import SwiftUI
import SwiftData

struct MyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TemplateItemEntity.createdDate, order: .reverse) 
    private var items: [TemplateItemEntity]
    
    func addItem(_ item: TemplateItem) {
        let entity = TemplateItemEntity(from: item)
        modelContext.insert(entity)
        try? modelContext.save()
    }
}
```

### Resources

- **Complete Guide**: `ios-template/Core/SwiftData/README.md`
- **Storage Comparison**: `Documentation/STORAGE_GUIDE.md`
- **Test Examples**: `ios-templateTests/SwiftDataTests.swift`

---

## Testing

### StoreKit Testing

1. Xcode will automatically use `configuration.storekit`
2. Run your app in the simulator or on device
3. Test purchase flow without real payments
4. Check console logs for transaction verification

### Testing Account Deletion

```swift
func testAccountDeletion() async throws {
    let deletionService = AccountDeletionService(
        persistenceService: mockPersistence,
        fileStorageProvider: mockStorage,
        syncService: nil,
        purchaseManager: purchaseManager
    )
    
    try await deletionService.deleteAllUserData()
    
    // Verify all data cleared
    let favorites = try await mockPersistence.loadFavorites()
    XCTAssertTrue(favorites.isEmpty)
}
```

---

## Next Steps

- Read the [Protocol Guide](PROTOCOL_GUIDE.md) for advanced protocol usage
- See the [Customization Guide](CUSTOMIZATION_GUIDE.md) for theming
- Check the [API Specification](API_SPECIFICATION.md) for backend integration
