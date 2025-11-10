# Customization Guide

This guide shows how to customize the design system and adapt components to your app's needs.

## Design System Customization

### Overriding Colors

Create an extension to override specific colors:

```swift
extension DesignSystem.Colors {
    static var appPrimary: Color {
        #if os(iOS)
        return Color(uiColor: UIColor { $0.userInterfaceStyle == .dark 
            ? .systemPurple 
            : .systemBlue 
        })
        #else
        return Color(nsColor: NSColor { $0.name == .darkAqua 
            ? .systemPurple 
            : .systemBlue 
        })
        #endif
    }
}

// Use in your views
Text("Hello")
    .foregroundColor(DesignSystem.Colors.appPrimary)
```

### Customizing Typography

Override typography scales:

```swift
extension DesignSystem.Typography {
    static var appTitle: Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static var appBody: Font {
        .system(size: 16, weight: .regular, design: .default)
    }
}
```

### Adjusting Spacing

Use the spacing system with your own values:

```swift
// Use existing tokens
.designPadding(.lg, .horizontal)

// Or create custom spacing
extension DesignSystem.Spacing {
    static let custom: CGFloat = 20
}
```

### Custom Shadows

Define app-specific shadows:

```swift
extension DesignSystem.Shadows {
    static let card = Shadow(
        radius: 12,
        offset: CGSize(width: 0, height: 6),
        opacity: 0.15
    )
}

// Apply
RoundedRectangle(cornerRadius: 16)
    .designShadow(DesignSystem.Shadows.card)
```

---

## Component Customization

### Custom Button Styles

Create variant buttons:

```swift
struct BrandButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.titleMedium)
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .designCornerRadius(DesignSystem.BorderRadius.lg)
        }
        .buttonStyle(PressableButtonStyle())
    }
}
```

### Custom Card Layouts

Extend the base card:

```swift
struct ProfileCard<Item: GenericItem>: View {
    let item: Item
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Avatar
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Text(String(item.creator.prefix(1)))
                            .font(DesignSystem.Typography.titleLarge)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                
                // Content
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(item.title)
                        .font(DesignSystem.Typography.titleMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(item.creator)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .designCornerRadius(DesignSystem.BorderRadius.md)
            .designShadow(DesignSystem.Shadows.small)
        }
        .buttonStyle(.plain)
    }
}
```

### Custom Empty States

```swift
struct CustomEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.primary.opacity(0.5))
            
            Text(title)
                .font(DesignSystem.Typography.headlineMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(message)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)
            
            PrimaryButton(title: "Get Started", action: action)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
}
```

---

## Motion Customization

### Custom Motion Tokens

```swift
extension DesignSystem.Animation {
    static let bounce: Animation = .spring(response: 0.4, dampingFraction: 0.6)
    static let smooth: Animation = .easeInOut(duration: 0.4)
}

// Use
Circle()
    .animation(DesignSystem.Animation.bounce, value: isActive)
```

---

## Theme System

### Creating a Theme Manager

```swift
@Observable
class ThemeManager {
    enum Theme {
        case light
        case dark
        case system
    }
    
    var currentTheme: Theme = .system {
        didSet {
            applyTheme()
        }
    }
    
    private func applyTheme() {
        switch currentTheme {
        case .light:
            // Set light mode
            break
        case .dark:
            // Set dark mode
            break
        case .system:
            // Use system setting
            break
        }
    }
}

// Inject into app
@main
struct YourApp: App {
    @State private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
        }
    }
}
```

---

## Adapting ModernItemCard

### Custom Metadata Display

```swift
func createMetadata(for item: Item) -> ItemCardMetadata {
    ItemCardMetadata(
        displayCategories: item.categories,
        badgeText: item.isNew ? "NEW" : item.primaryCategory,
        badgeColor: item.isNew ? DesignSystem.Colors.accent : nil,
        attachmentLabel: item.hasAttachment ? "📄 PDF" : nil,
        attachmentIcon: "doc.richtext.fill"
    )
}
```

### Subclassing for Domain Logic

```swift
struct ItemCard: View {
    let item: Item
    @Environment(ItemDataManager.self) private var dataManager
    
    var body: some View {
        ModernItemCard(
            item: item,
            metadata: itemMetadata,
            onTap: { openItem() },
            onFavorite: { dataManager.toggleFavorite(item) },
            onShare: { shareItem() }
        )
        .overlay(alignment: .topTrailing) {
            if item.isNew {
                Text("NEW")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DesignSystem.Colors.accent)
                    .clipShape(Capsule())
                    .offset(x: -8, y: 8)
            }
        }
    }
    
    private var itemMetadata: ItemCardMetadata {
        ItemCardMetadata(
            displayCategories: item.categories,
            badgeText: item.domain.uppercased(),
            attachmentLabel: "PDF"
        )
    }
}
```

---

## Platform-Specific Customization

### iOS vs macOS

```swift
struct AdaptiveCard<Item: GenericItem>: View {
    let item: Item
    
    var body: some View {
        #if os(iOS)
        IOSCard(item: item)
        #else
        MacOSCard(item: item)
        #endif
    }
}

struct IOSCard<Item: GenericItem>: View {
    let item: Item
    
    var body: some View {
        ModernItemCard(
            item: item,
            metadata: ItemCardMetadata(displayCategories: item.categories),
            interactionStyle: .button,
            onTap: { }
        )
        .cardParallax(id: item.id)  // Enable on iOS
    }
}

struct MacOSCard<Item: GenericItem>: View {
    let item: Item
    
    var body: some View {
        ModernItemCard(
            item: item,
            metadata: ItemCardMetadata(displayCategories: item.categories),
            interactionStyle: .staticLabel,  // Different on macOS
            onTap: { }
        )
    }
}
```

---

## Accessibility Customization

### Custom Dynamic Type

```swift
extension DesignSystem.Typography {
    @ScaledMetric(relativeTo: .title) static var scalableTitle: CGFloat = 22
    @ScaledMetric(relativeTo: .body) static var scalableBody: CGFloat = 16
}

Text("Hello")
    .font(.system(size: DesignSystem.Typography.scalableTitle))
```

### VoiceOver Labels

```swift
ModernItemCard(item: item, metadata: metadata, onTap: {})
    .accessibilityLabel("\(item.title), by \(item.creator)")
    .accessibilityHint("Double tap to read item")
    .accessibilityAddTraits(.isButton)
```

---

## Best Practices

1. **Extend, Don't Modify** - Create extensions instead of modifying source files
2. **Consistent Naming** - Use `app` prefix for custom tokens
3. **Respect System Settings** - Honor dark mode, reduce motion, etc.
4. **Test Accessibility** - Verify with VoiceOver and Dynamic Type
5. **Document Customizations** - Keep a style guide for your team

---

## Next Steps

- Review [Integration Guide](INTEGRATION_GUIDE.md) for setup
- Check [Protocol Guide](PROTOCOL_GUIDE.md) for implementation details
