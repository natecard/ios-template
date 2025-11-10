# iOS/macOS App Template

A comprehensive, production-ready template for iOS and macOS applications featuring:

- **Complete Design System** with 50+ color tokens, typography scales, and spacing system
- **40+ UI Components** including buttons, cards, inputs, feedback, and modern list views
- **In-App Purchase System** with StoreKit 2 integration and server validation
- **Generic Protocols** for maximum reusability across different app domains
- **Motion & Accessibility** support with user preferences and system settings
- **Account Management** with data deletion and iCloud sync support

## Quick Start

### 1. Install the Template

Copy the `ios-template/` directory into your Xcode project.

### 2. Configure Your Domain Model

Implement the `GenericItem` protocol for your content type:

```swift
struct Item: GenericItem {
    let id: String
    let title: String
    let summary: String  // Your abstract/description field
    let creator: String  // Your author/artist field
    let createdDate: Date
    let categories: [String]
    let primaryCategory: String
    let hasAttachment: Bool
    let attachmentURL: URL?
    
    // Optional: provide richer metadata
    var metadata: [ItemMetadataEntry] {
        categories.map { ItemMetadataEntry(key: "category", value: $0, presentation: .tag) }
    }
}
```

### 3. Set Up In-App Purchases

Add to your `Info.plist`:

```xml
<key>IAPProductID</key>
<string>com.yourcompany.yourapp.full_unlock</string>
<key>IAPValidationURL</key>
<string>https://your-api.com/api/iap/validate</string>
<key>IAPValidationURLSandbox</key>
<string>https://your-api.com/api/iap/validate/sandbox</string>
```

### 3. Add Purchase Manager

```swift
import SwiftUI

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

> **⚠️ Important**: Always call `purchaseManager.start()` in `.onAppear` to initialize StoreKit transaction listeners. Without this call, purchase restoration and transaction updates will not work.

### 5. Use the Components

```swift
struct ContentView: View {
    @State private var items: [Item] = []
    
    var body: some View {
        ModernItemListView(
            items: items,
            metadata: { item in
                ItemCardMetadata(
                    displayCategories: item.categories,
                    badgeText: item.primaryCategory,
                    attachmentLabel: "PDF"
                )
            },
            onItemTap: { item in
                // Handle tap
            }
        )
    }
}
```

## What's Included

### Design System
- **DesignSystem.swift**: 50+ colors, typography, spacing, shadows, animations
- Complete documentation in `ios-template/DesignSystem/`

### UI Components

**Buttons**: Primary, Secondary, Ghost, Icon, FAB, Animated  
**Cards**: Base, Interactive, Info, Empty State with parallax support  
**Inputs**: Search, TextField, Segmented Control, Toggle, Slider  
**Feedback**: Loading, Skeleton, Progress, Toast, Status Badge  
**Modern**: Item Cards, Item Lists, Search Bar with suggestions  

### Purchase System
- **PurchaseManager**: StoreKit 2 integration with server validation
- **AccountDeletionService**: Complete user data deletion
- **FullUnlockPaywallView**: Ready-to-use paywall UI
- Backend API specification included

### Protocols
- **GenericItem**: Define your content type
- **GenericCollection**: Group items into collections
- **PersistenceServiceProtocol**: Generic data persistence
- **FileStorageProviderProtocol**: Generic file storage (local + iCloud)

## Documentation

- **[Integration Guide](Documentation/INTEGRATION_GUIDE.md)**: Step-by-step setup
- **[Protocol Guide](Documentation/PROTOCOL_GUIDE.md)**: Implementing protocols
- **[Customization Guide](Documentation/CUSTOMIZATION_GUIDE.md)**: Theming and adaptation
- **[API Specification](Documentation/API_SPECIFICATION.md)**: Backend validation endpoints
- **[Configuration](CONFIGURATION.md)**: Info.plist and StoreKit setup
- **[CI/CD Setup](CI_CD_SETUP.md)**: GitHub Actions, linting, and formatting

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 6.0+
- Xcode 16.0+

## Features

✅ **Zero External Dependencies** - Pure SwiftUI + Foundation  
✅ **Fully Generic** - Works with any content type  
✅ **Accessibility First** - VoiceOver, Dynamic Type, Reduce Motion support  
✅ **Production Ready** - Used in shipped apps  
✅ **Well Documented** - Comprehensive guides and code comments  
✅ **Type Safe** - Leverages Swift's type system for safety  
✅ **CI/CD Ready** - GitHub Actions workflows for testing, formatting, and releases  

## License

This template is provided as-is for use in your projects. Modify and adapt as needed.

## Credits
Maintained by Nate Card - [natecard.dev](https://natecard.dev)