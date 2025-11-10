# Quick Reference

## Common Tasks

### Basic Setup

```swift
// 1. Configure Info.plist
IAPProductID = "com.yourapp.unlock"
IAPValidationURL = "https://api.yourapp.com/validate"

// 2. Implement GenericItem
struct Item: GenericItem { /* ... */ }

// 3. Initialize in App
@main
struct YourApp: App {
    @State private var purchaseManager = PurchaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseManager)
                .onAppear { purchaseManager.start() }
        }
    }
}
```

    ### Dependency Injection (Quick Start)

    ```swift
    // Build container (app start)
    let container = AppContainer.buildApp()

    // Inject into environment
    RootView()
        .environment(\.appContainer, container)

    // Resolve in a view
    struct FeatureView: View {
        @Injected private var viewModel: ItemsListViewModel
        var body: some View { /* ... */ }
    }

    // Override for tests
    let testContainer = AppContainer.buildTest(overrides: [MockAssembly()])
    ```

    Key Docs: `DI_GUIDE.md` (architecture), `AppContainer`, `ServiceAssembly`, `@Injected`.

---

## Component Cheat Sheet

### Buttons

```swift
PrimaryButton(title: "Save", icon: "checkmark", action: save)
SecondaryButton(title: "Cancel", action: cancel)
GhostButton(title: "Delete", action: delete)
IconButton(icon: "heart", size: .medium, style: .primary, action: favorite)
```

### Cards

```swift
// Basic card
BaseCard { Text("Content") }

// Interactive card
InteractiveCard(isSelected: true) { Text("Content") }

// Empty state
EmptyStateCard(
    icon: "tray",
    title: "No Items",
    message: "Add your first item",
    actionTitle: "Add Item",
    action: addItem
)
```

### Modern Item Card

```swift
ModernItemCard(
    item: item,
    metadata: ItemCardMetadata(
        displayCategories: item.categories,
        badgeText: item.domain,
        attachmentLabel: "PDF"
    ),
    onTap: { openItem() },
    onFavorite: { toggleFavorite() },
    onShare: { shareItem() }
)
```

### Modern List

```swift
ModernItemListView(
    items: items,
    metadata: { item in ItemCardMetadata(...) },
    isLoading: viewModel.isLoading,
    errorMessage: viewModel.error,
    onItemTap: { item in /* ... */ },
    onFavorite: { item in /* ... */ }
)
```

### Search

```swift
ModernSearchBar(
    text: $searchText,
    placeholder: "Search...",
    showSuggestions: true,
    suggestions: ["AI", "ML", "Science"],
    onSuggestionTap: { search($0) },
    onSearch: { performSearch() }
)
```

### Inputs

```swift
// Search
SearchBar(text: $query, placeholder: "Search...")

// Text field (iOS only)
TextInputField(
    text: $name,
    placeholder: "Name",
    errorMessage: errorMsg
)

// Segmented control
SegmentedControl(selection: $tab, items: ["All", "Favorites"])

// Toggle
ToggleSwitch(
    title: "Notifications",
    subtitle: "Get updates",
    isOn: $notificationsEnabled
)
```

### Feedback

```swift
// Loading
LoadingView(message: "Loading...", style: .large)

// Skeleton
ItemSkeleton()

// Progress
ProgressBar(progress: 0.75, title: "Download", showPercentage: true)

// Toast
ToastNotification(
    title: "Success",
    message: "Item saved",
    type: .success
)
```

---

## Design System

### Colors

```swift
DesignSystem.Colors.primary
DesignSystem.Colors.secondary
DesignSystem.Colors.textPrimary
DesignSystem.Colors.surface
DesignSystem.Colors.background
```

### Typography

```swift
.font(DesignSystem.Typography.displayLarge)
.font(DesignSystem.Typography.titleMedium)
.font(DesignSystem.Typography.bodyMedium)
.font(DesignSystem.Typography.labelSmall)
```

### Spacing

```swift
.designPadding(.md, .horizontal)
.designPadding(.lg, .vertical)

DesignSystem.Spacing.xs  // 4
DesignSystem.Spacing.sm  // 8
DesignSystem.Spacing.md  // 16
DesignSystem.Spacing.lg  // 24
DesignSystem.Spacing.xl  // 32
```

### Modifiers

```swift
.designCornerRadius(DesignSystem.BorderRadius.lg)
.designShadow(DesignSystem.Shadows.medium)
```

---

## Networking

- Configure base URLs in Info.plist:
  - `APIBaseURL` — default API base
  - `IAPValidationURL` — production IAP validation
  - `IAPValidationURLSandbox` — sandbox IAP validation (optional)
- `NetworkClientProtocol` is resolved via DI and implemented by `AlamofireNetworkClient`.
- Use `ItemRepository` and other repositories/services instead of calling Alamofire directly.
- See `NETWORKING_GUIDE.md` for details.

## Purchase System

### Initialize PurchaseManager

```swift
@main
struct YourApp: App {
    @State private var purchaseManager = PurchaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseManager)
                .onAppear {
                    purchaseManager.start()  // ⚠️ REQUIRED
                }
        }
    }
}
```

> **⚠️ Warning**: Always call `purchaseManager.start()` to initialize StoreKit listeners.

### Show Paywall

```swift
@Environment(PurchaseManager.self) private var purchaseManager

Button("Upgrade") {
    purchaseManager.presentPaywall(source: "upgrade-button")
}
.sheet(isPresented: $purchaseManager.isPaywallPresented) {
    FullUnlockPaywallView()
}
```

### Check Unlock Status

```swift
if purchaseManager.isFullAppUnlocked {
    PremiumFeature()
} else {
    LockedView {
        purchaseManager.presentPaywall()
    }
}
```

### Restore Purchases

```swift
Task {
    await purchaseManager.restorePurchases()
}
```

---

## Protocols

### GenericItem

```swift
struct MyItem: GenericItem {
    let id: String
    let title: String
    let summary: String
    let creator: String
    let createdDate: Date
    let categories: [String]
    let primaryCategory: String
    let hasAttachment: Bool
    let attachmentURL: URL?
}
```

### GenericCollection

```swift
@Observable
class MyCollection: GenericCollection {
    typealias Item = MyItem
    var id = UUID()
    var items: [MyItem]
    var heading: String?
}
```

### GenericDataManager

```swift
@MainActor
@Observable
class DataManager: GenericDataManager {
    typealias Item = MyItem
    typealias Collection = MyCollection
    
    var items: [MyItem] = []
    var favoriteItems: [MyItem] = []
    var userCollections: [MyCollection] = []
    
    func isFavorite(_ item: MyItem) -> Bool { /* ... */ }
    func toggleFavorite(_ item: MyItem) { /* ... */ }
    func addFavorite(_ item: MyItem) { /* ... */ }
    func removeFavorite(_ item: MyItem) { /* ... */ }
}
```

---

## File Storage

```swift
// Store file
let url = try await storage.store(
    data: fileData,
    for: item,
    scope: .local,
    fileExtension: .pdf
)

// Check if exists
let exists = await storage.exists(
    for: item,
    scope: .local,
    fileExtension: .pdf
)

// Get URL
if let url = await storage.url(for: item, scope: .local, fileExtension: .pdf) {
    // Use URL
}

// Delete all files
try await storage.deleteAllFiles(scope: .local, fileExtension: .pdf)
```

---

## Persistence

```swift
// Save favorites
try await persistence.saveFavorites(favorites)

// Load favorites
let favorites = try await persistence.loadFavorites()

// Save collections
try await persistence.saveCollections(collections)

// Load collections
let collections = try await persistence.loadCollections()

// Clear all
try await persistence.clearAllData()
```

---

## Common Patterns

### List with Pull to Refresh

```swift
ScrollView {
    ModernItemListView(items: items, ...)
}
.refreshable {
    await loadItems()
}
```

### Navigation

```swift
NavigationStack {
    ModernItemListView(
        items: items,
        onItemTap: { item in
            selectedItem = item
        }
    )
    .navigationDestination(item: $selectedItem) { item in
        DetailView(item: item)
    }
}
```

### Search + Filter

```swift
VStack {
    ModernSearchBar(text: $searchText, ...)
    
    ModernItemListView(
        items: filteredItems,
        ...
    )
}

var filteredItems: [Item] {
    items.filter { item in
        searchText.isEmpty || 
        item.title.localizedCaseInsensitiveContains(searchText)
    }
}
```

---

## Troubleshooting

### "IAPProductID not found"
Add `IAPProductID` key to Info.plist

### Components not showing colors correctly
Ensure `DesignSystem.Colors` is imported and colors work in both light/dark mode

### Generic type errors
Ensure your types conform to required protocols (`GenericItem`, `Codable`, `Sendable`)

---

## CI/CD Commands

### Local Development

```bash
# Install tools (macOS)
brew install swiftlint swift-format

# Run linter
./scripts/lint.sh

# Auto-format code
./scripts/format.sh

# Set up pre-commit hooks
./scripts/setup-git-hooks.sh

# Check formatting without changing
swift-format lint --recursive ios-template/ --strict
```

### GitHub Actions

**Workflows automatically run on:**
- Push/PR to `main` or `develop` → CI tests
- Push to `develop` → Auto-format
- Push tag `v*` → Release build

**Manual trigger:**
1. Go to Actions tab
2. Select "Format Code"
3. Click "Run workflow"

---

## File Locations

- **Design System**: `ios-template/DesignSystem/`
- **UI Components**: `ios-template/UIComponents/`
- **Protocols**: `ios-template/Protocols/`
- **Purchase System**: `ios-template/Services/Monetization/Purchases/`
- **Documentation**: `Documentation/`
- **CI/CD Config**: `ci-cd/.github/workflows/`, `ci-cd/scripts/`

---

## Get Help

- **Integration Guide**: `Documentation/INTEGRATION_GUIDE.md`
- **Protocol Guide**: `Documentation/PROTOCOL_GUIDE.md`
- **Customization**: `Documentation/CUSTOMIZATION_GUIDE.md`
- **API Docs**: `Documentation/API_SPECIFICATION.md`
- **CI/CD Setup**: `CI_CD_SETUP.md`
- **Dependency Injection**: `DI_GUIDE.md`
