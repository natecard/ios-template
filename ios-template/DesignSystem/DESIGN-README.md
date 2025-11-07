# Design System & UI Components

This directory contains a comprehensive design system and reusable UI components for your application. The goal is to create a cohesive, professional appearance that feels modern and polished without being overwhelming.

## 🎨 Design Philosophy

- **Consistency**: All components use the same design tokens (colors, typography, spacing, etc.)
- **Accessibility**: Components are built with accessibility in mind
- **Performance**: Minimal animations and effects to maintain smooth performance
- **Adaptability**: Components work across iOS and macOS with appropriate adaptations
- **Vibrancy**: Modern, engaging color palette that maintains professional appeal

## 🏗️ Architecture

### Core Design System (`DesignSystem.swift`)
The foundation that defines:
- **Colors**: Vibrant, accessible color palette with semantic meaning
- **Typography**: Consistent font sizes and weights
- **Spacing**: Standardized spacing values
- **Border Radius**: Consistent corner radius values
- **Shadows**: Subtle shadow definitions
- **Animations**: Standardized animation durations and curves

### Component Categories

#### 1. **Button Components** (`ButtonComponents.swift`)
- `PrimaryButton`: Main call-to-action buttons
- `SecondaryButton`: Secondary actions with outline style
- `GhostButton`: Subtle actions with background tint
- `IconButton`: Icon-only buttons in various sizes and styles
- `FloatingActionButton`: Prominent floating action button
- `InteractiveButtonStyle`: Button style modifier for consistent interactions

#### 2. **Card Components** (`CardComponents.swift`)
- `BaseCard`: Foundation card with customizable styling
- `InteractiveCard`: Selectable cards with selection states
- `ItemCard`: Specialized card for item display
- `InfoCard`: Informational cards with different styles (info, success, warning, error)
- `EmptyStateCard`: Cards for empty states with optional actions

#### 3. **Input Components** (`InputComponents.swift`)
- `SearchBar`: Enhanced search input with clear and search actions
- `TextInputField`: Form input fields with validation support
- `SegmentedControl`: Custom segmented control with icons
- `ToggleSwitch`: Toggle switches with labels and descriptions
- `SliderInput`: Slider inputs with value formatting

#### 4. **Feedback Components** (`FeedbackComponents.swift`)
- `LoadingView`: Loading states with customizable messages
- `SkeletonView`: Skeleton loading placeholders
- `ItemSkeleton`: Pre-built skeleton for item cards
- `ProgressBar`: Progress indicators with different styles
- `ToastNotification`: Toast notifications with different types
- `PullToRefreshView`: Pull-to-refresh indicator

#### 5. **Modern Components** (New!)
- `ModernSearchBar`: Enhanced search bar with suggestions and modern styling
- `ModernItemCard`: Contemporary item display with hover effects and actions
- `ModernItemListView`: Complete item list with loading, error, and empty states

#### 6. **Settings Components** (`SettingsComponents.swift`)
- `SettingsRow`: Key-value display row for settings information
- `SettingsLinkRow`: Label with action button for navigation or external links
- `SettingsSectionDivider`: Standardized divider for separating setting items

## 🌈 Color System & Usage Guidelines

### **Primary Color Palette**
Our color system is built around a modern, vibrant palette that maintains accessibility while adding visual interest:

#### **Primary Colors (Teal/Cyan)**
- **`primary`** - Main brand color for primary actions, links, and key UI elements
- **`primaryLight`** - Hover states, secondary emphasis, and lighter backgrounds
- **`primaryDark`** - Active states, pressed buttons, and strong emphasis

**Usage**: Main call-to-action buttons, primary navigation, links, and key interactive elements

#### **Secondary Colors (Warm Coral)**
- **`secondary`** - Secondary actions, highlights, and complementary elements
- **`secondaryLight`** - Light backgrounds, subtle highlights, and secondary surfaces
- **`secondaryDark`** - Strong secondary emphasis and dark secondary elements

**Usage**: Secondary buttons, highlights, accents, and complementary UI elements

#### **Accent Colors (Soft Purple)**
- **`accent`** - Special features, premium elements, and unique interactions
- **`accentLight`** - Light accent backgrounds and subtle purple tints
- **`accentDark`** - Strong accent emphasis and dark accent elements

**Usage**: Premium features, special interactions, and unique UI elements

### **Semantic Colors**
Colors that convey meaning and should be used consistently:

#### **Success States**
- **`success`** - Successful actions, completed states, and positive feedback
- **Usage**: Download complete, save successful, validation passed

#### **Warning States**
- **`warning`** - Cautionary information, pending actions, and attention needed
- **Usage**: Incomplete forms, pending downloads, attention required

#### **Error States**
- **`error`** - Errors, failed actions, and critical issues
- **Usage**: Download failed, validation errors, critical warnings

#### **Info States**
- **`info`** - Informational content, help text, and general information
- **Usage**: Help text, informational tooltips, general guidance

### **Neutral Colors**
Warm, sophisticated grays that provide structure without being cold:

#### **Background Colors**
- **`background`** - Main app background (system adaptive)
- **`secondaryBackground`** - Secondary surfaces, card backgrounds
- **`tertiaryBackground`** - Tertiary surfaces, subtle backgrounds

#### **Surface Colors**
- **`surface`** - Main content surfaces (system adaptive)
- **`surfaceSecondary`** - Secondary content areas
- **`surfaceTertiary`** - Tertiary content areas

#### **Border Colors**
- **`border`** - Primary borders and separators
- **`borderLight`** - Subtle borders and light separators

### **Text Colors**
Enhanced contrast for better readability:

- **`textPrimary`** - Main text content (system adaptive)
- **`textSecondary`** - Secondary text, subtitles, and descriptions
- **`textTertiary`** - Tertiary text, metadata, and subtle information
- **`textQuaternary`** - Quaternary text, disabled states, and very subtle information

### **Special Purpose Colors**

#### **Highlight Colors**
- **`highlight`** - Background for highlighted content and selections
- **`highlightText`** - Text color for highlighted content

#### **Code & Technical Colors**
- **`code`** - Background for code blocks and technical content
- **`codeText`** - Text color for code and technical content

#### **Link Colors**
- **`link`** - Hyperlinks and clickable text elements

## 🎯 Color Usage Rules

### **1. Primary Actions**
- Use `primary` for main call-to-action buttons
- Use `primaryLight` for hover states
- Use `primaryDark` for pressed/active states

### **2. Secondary Actions**
- Use `secondary` for secondary buttons and actions
- Use `secondaryLight` for subtle secondary elements
- Use `secondaryDark` for strong secondary emphasis

### **3. Semantic Meaning**
- **Always** use semantic colors for their intended purpose
- Success = `success` (never use primary for success)
- Warning = `warning` (never use secondary for warnings)
- Error = `error` (never use accent for errors)

### **4. Text Hierarchy**
- **Primary text**: `textPrimary` for main content
- **Secondary text**: `textSecondary` for subtitles and descriptions
- **Tertiary text**: `textTertiary` for metadata and subtle information
- **Quaternary text**: `textQuaternary` for disabled states and very subtle info

### **5. Background & Surface Usage**
- **Main backgrounds**: `background` (system adaptive)
- **Card surfaces**: `surface` or `surfaceSecondary`
- **Subtle backgrounds**: `surfaceTertiary` or `secondaryBackground`
- **Interactive backgrounds**: Use primary/secondary colors with appropriate opacity

### **6. Border Usage**
- **Primary borders**: `border` for main separators
- **Subtle borders**: `borderLight` for light separators
- **Interactive borders**: Use primary/secondary colors for focus states

## 🚀 Usage Examples

### Basic Button Usage
```swift
PrimaryButton("Download PDF", icon: "arrow.down.circle") {
    // Handle download
}

SecondaryButton("Cancel", icon: "xmark") {
    // Handle cancellation
}
```

### Card Usage
```swift
ItemCard(
    title: item.title,
    subtitle: item.author,
    description: item.abstract,
    metadata: item.categories,
    isSelected: selectedItem == item
) {
    // Handle selection
}
```

### Search Bar Usage
```swift
SearchBar(
    text: $searchText,
    placeholder: "Search items..."
) {
    // Handle search
} onClear: {
    // Handle clear
}
```

### Loading States
```swift
if isLoading {
    LoadingView(message: "Loading items...", style: .large)
} else {
    // Content
}
```

### Modern Components
```swift
// Enhanced search bar with suggestions
ModernSearchBar(
    text: $searchText,
    placeholder: "Search items...",
    showSuggestions: true,
    suggestions: ["machine learning", "AI", "computer vision"]
) {
    performSearch()
} onClear: {
    clearSearch()
}

// Modern item card with actions
ModernItemCard(
    item: item,
    isSelected: selectedItem == item,
    showActions: true
) {
    selectItem(item)
} onFavorite: {
    toggleFavorite(item)
} onShare: {
    shareItem(item)
}

// Complete item list with all states
ModernItemListView(
    items: items,
    isLoading: isLoading,
    errorMessage: errorMessage,
    onItemTap: { item in
        navigateToItem(item)
    },
    onFavorite: { item in
        toggleFavorite(item)
    },
    onShare: { item in
        shareItem(item)
    },
    onRetry: {
        loadItems()
    }
)
```

### Settings Components
```swift
// Display key-value information
SettingsRow(label: "Version", value: "1.0.0")

// Divider between settings items
SettingsSectionDivider()

// Link row with action button
SettingsLinkRow(
    label: "Developed by",
    buttonText: "Visit Website"
) {
    // Handle action (e.g., open web view)
    showWebView = true
}

// In a settings section
Section(header: Text("About")) {
    VStack(spacing: 0) {
        SettingsRow(label: "Version", value: appVersion)
        SettingsSectionDivider()
        SettingsRow(label: "Build", value: buildNumber)
        SettingsSectionDivider()
        SettingsLinkRow(label: "Support", buttonText: "Contact Us") {
            openSupportPage()
        }
    }
}
```

### Color Usage Examples
```swift
// Primary action button
PrimaryButton("Save Item") {
    // Save action
}

// Success state
InfoCard(
    icon: "checkmark.circle",
    title: "Success!",
    message: "Item saved to collection",
    style: .success
)

// Warning state
InfoCard(
    icon: "exclamationmark.triangle",
    title: "Attention",
    message: "Please complete required fields",
    style: .warning
)

// Error state
InfoCard(
    icon: "xmark.circle",
    title: "Error",
    message: "Failed to download PDF",
    style: .error
)
```

## 🎯 Implementation Guidelines

### 1. **Always Use Design System Tokens**
```swift
// ✅ Good
Text("Title")
    .font(DesignSystem.Typography.titleLarge)
    .foregroundColor(DesignSystem.Colors.textPrimary)
    .padding(DesignSystem.Spacing.md)

// ❌ Bad
Text("Title")
    .font(.title)
    .foregroundColor(.primary)
    .padding(16)
```

### 2. **Use Appropriate Component Variants**
- Use `PrimaryButton` for main actions
- Use `SecondaryButton` for secondary actions
- Use `GhostButton` for subtle actions
- Use `IconButton` for icon-only interactions

### 3. **Consistent Spacing**
- Use `DesignSystem.Spacing` values consistently
- Group related elements with `DesignSystem.Spacing.sm`
- Separate sections with `DesignSystem.Spacing.md` or larger

### 4. **Color Usage**
- Use semantic colors for their intended purpose
- Use system colors for backgrounds and surfaces
- Maintain proper contrast ratios
- Follow the color hierarchy rules above

## 🔧 Customization

### Extending the Design System
To add new design tokens:

```swift
extension DesignSystem.Colors {
    static let customColor = Color(red: 0.8, green: 0.6, blue: 0.4)
}

extension DesignSystem.Typography {
    static let customFont = Font.system(size: 18, weight: .medium)
}
```

### Creating New Components
When creating new components:

1. Use the existing design tokens
2. Follow the established naming conventions
3. Include proper accessibility support
4. Add previews for development
5. Document the component's purpose and usage

### Component Composition
Components are designed to be composable:

```swift
BaseCard(
    backgroundColor: DesignSystem.Colors.surface,
    shadow: DesignSystem.Shadows.medium
) {
    VStack(spacing: DesignSystem.Spacing.md) {
        // Your content here
    }
}
```

## 📱 Platform Considerations

### iOS vs macOS
- Components automatically adapt to platform differences
- Use `#if os(iOS)` / `#if os(macOS)` for platform-specific logic
- Maintain consistent visual hierarchy across platforms

### Accessibility
- All components include proper accessibility labels
- Support for Dynamic Type
- Proper contrast ratios (all colors meet WCAG AA standards)
- VoiceOver support

## 🧪 Testing

### Preview Support
All components include SwiftUI previews for development:

```swift
#if DEBUG
struct ComponentName_Previews: PreviewProvider {
    static var previews: some View {
        ComponentName()
            .padding()
            .background(DesignSystem.Colors.background)
    }
}
#endif
```

### Testing Guidelines
- Test components with different content lengths
- Verify accessibility features
- Test on different device sizes
- Verify platform-specific behavior
- Test color contrast ratios

## 📚 Migration Guide

### From Old Components
When migrating existing views:

1. Replace hardcoded values with design system tokens
2. Use new component variants where appropriate
3. Update spacing and typography consistently
4. Test for visual regressions
5. Verify color accessibility

### Example Migration
```swift
// Before
Button("Download") {
    // action
}
.padding(16)
.background(Color.blue)
.foregroundColor(.white)
.cornerRadius(8)

// After
PrimaryButton("Download") {
    // action
}
```

## 🎨 Design Tokens Reference

### Colors
- **Primary**: `DesignSystem.Colors.primary` - Main brand color (teal)
- **Secondary**: `DesignSystem.Colors.secondary` - Secondary color (coral)
- **Accent**: `DesignSystem.Colors.accent` - Accent color (purple)
- **Success**: `DesignSystem.Colors.success` - Success states (fresh green)
- **Warning**: `DesignSystem.Colors.warning` - Warning states (warm amber)
- **Error**: `DesignSystem.Colors.error` - Error states (vibrant red)
- **Info**: `DesignSystem.Colors.info` - Info states (bright blue)
- **Background**: `DesignSystem.Colors.background` - Main background
- **Surface**: `DesignSystem.Colors.surface` - Card surfaces
- **Text Primary**: `DesignSystem.Colors.textPrimary` - Primary text
- **Text Secondary**: `DesignSystem.Colors.textSecondary` - Secondary text

### Typography
- `DesignSystem.Typography.displayLarge` - Large display text
- `DesignSystem.Typography.headlineLarge` - Large headlines
- `DesignSystem.Typography.titleLarge` - Large titles
- `DesignSystem.Typography.bodyLarge` - Large body text
- `DesignSystem.Typography.labelLarge` - Large labels

### Spacing
- `DesignSystem.Spacing.xs` - 4pt
- `DesignSystem.Spacing.sm` - 8pt
- `DesignSystem.Spacing.md` - 16pt
- `DesignSystem.Spacing.lg` - 24pt
- `DesignSystem.Spacing.xl` - 32pt

### Border Radius
- `DesignSystem.BorderRadius.xs` - 4pt
- `DesignSystem.BorderRadius.sm` - 8pt
- `DesignSystem.BorderRadius.md` - 12pt
- `DesignSystem.BorderRadius.lg` - 16pt

## 🤝 Contributing

When adding new components or modifying existing ones:

1. Follow the established patterns
2. Use design system tokens consistently
3. Include comprehensive previews
4. Add proper documentation
5. Test across platforms
6. Verify accessibility compliance
7. Ensure color contrast meets accessibility standards

## 🎨 Animations

Animations play a crucial role in creating a dynamic and engaging user interface. When implemented thoughtfully, they can guide users through the app, provide feedback, and make interactions feel more natural.

### Best Practices

1. **Purposeful Animations**: Ensure that each animation serves a clear purpose, such as drawing attention to a change, indicating progress, or providing feedback. Avoid unnecessary animations that may distract or confuse users.

2. **Consistency**: Maintain consistency in animation styles and durations throughout the app to create a cohesive user experience.

3. **Performance Optimization**: Optimize animations to ensure they run smoothly across all devices. Utilize hardware acceleration and minimize the number of animated properties to maintain performance.

4. **User Control**: Allow users to control or disable animations, especially for those who may have motion sensitivities. Respect system-wide settings related to motion and accessibility.

5. **Subtlety**: Use subtle animations to enhance the user experience without overwhelming the interface. Overly complex or flashy animations can detract from usability.

### Recommended Animation Techniques

- **Implicit Animations**: Utilize SwiftUI's `animation` modifier for simple state changes. This approach is suitable for animating properties like opacity, scale, or position when the state changes.

- **Explicit Animations**: For more control over animations, use the `withAnimation` function to wrap state changes. This method allows for specifying the animation type and duration explicitly.

- **Spring Animations**: Implement spring animations to create realistic motion effects. SwiftUI provides built-in support for spring animations, which can be customized for damping and stiffness.

- **Transition Animations**: Use transitions to animate the appearance and disappearance of views. SwiftUI offers various built-in transitions like `.slide`, `.opacity`, and `.scale`.

- **Matched Geometry Effect**: For complex animations involving multiple views, consider using the `matchedGeometryEffect` modifier to create smooth transitions between views.

### Animation Recommendations

Below are tailored animation recommendations for different parts of the app, focusing on iOS 18 and earlier for broad compatibility. These are designed to be beautiful, performant, and contextually appropriate.

#### 1. **Bouncy/Snappy Transitions for Page or Item Swipes** (iOS 17+)
   - **Where to Use**: Item card transitions, PDF page flips, or search result swipes.
   - **How to Implement**: Wrap views in `withAnimation(.bouncy) { ... }` or use `.transition(.move(edge: .leading).combined(with: .opacity).animation(.snappy))`. For PDF pages, apply to `scaleEffect` or `offset`.
   - **Why Suitable**: Provides playful, responsive feedback for navigation, enhancing engagement without overwhelming the academic content.
   - **Performance Note**: Optimized by SwiftUI's engine for smooth rendering on A14+ chips.

#### 2. **Parallax Scrolling Effects in Item Lists** (iOS 16+)
   - **Where to Use**: Item feed, search results list, or thumbnail grids.
   - **How to Implement**: Use `GeometryReader` with `ScrollView`: `.offset(y: geo.frame(in: .global).minY * 0.1).animation(.easeOut)`. Combine with `LazyVStack` for efficiency.
   - **Why Suitable**: Adds depth to long lists, making browsing feel more immersive and dynamic.
   - **Performance Note**: Leverages Metal for efficient rendering; test on older devices to ensure no lag.

#### 3. **Smooth Modal/Sheet Presentations with Blur** (iOS 18+)
   - **Where to Use**: PDF viewer modals, item detail sheets, or settings overlays.
   - **How to Implement**: Use `.sheet` or `.fullScreenCover` with `.interactiveSpring` and system blur effects (e.g., `UIBlurEffect`). Add `.scaleEffect(0.95).animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7))`.
   - **Why Suitable**: Creates polished, native-feeling presentations for detailed content like PDFs or items.
   - **Performance Note**: iOS 18's graphics pipeline handles blur and springs efficiently.

#### 4. **Fade-in Staggered Animations for List Rows** (iOS 16+)
   - **Where to Use**: Item list loading, search result reveals, or card grids.
   - **How to Implement**: In `ForEach`, use `.onAppear { withAnimation(.easeInOut.delay(Double(index) * 0.1)) { opacity = 1 } }`. Limit to 10-20 items.
   - **Why Suitable**: Smoothly reveals content, reducing perceived load time and adding polish to lists.
   - **Performance Note**: Batched by SwiftUI; ensure lightweight for large datasets.

#### 5. **Interactive Drag Gestures with Snapback** (iOS 17+)
   - **Where to Use**: Dragging item cards for favoriting, PDF bookmarks, or reordering.
   - **How to Implement**: Apply `.draggable(item) { DragPreview() }.dropDestination { ... }` with `.animation(.interactiveSpring())`.
   - **Why Suitable**: Adds tactile feedback for user interactions, enhancing usability in a reader app.
   - **Performance Note**: iOS 17's gesture recognizers are low-latency; avoid heavy computations in handlers.

#### 6. **Subtle Hover/Press Effects on Buttons** (iOS 17+)
   - **Where to Use**: Buttons in `ItemFileButtons`, `DetailedItemAuthors`, or navigation controls.
   - **How to Implement**: Custom `ButtonStyle` with `scaleEffect(isPressed ? 0.95 : 1).animation(.easeOut(duration: 0.1))`.
   - **Why Suitable**: Provides instant visual feedback for interactive elements.
   - **Performance Note**: Efficient rendering; respect `reduceMotion` settings.

#### 7. **Smooth Page Curl for PDF Viewer** (iOS 18+)
   - **Where to Use**: PDF page transitions in the viewer.
   - **How to Implement**: Use `UIView` with `CATransform3D` and `CABasicAnimation` for 3D effects.
   - **Why Suitable**: Mimics a book-like experience for academic content.
   - **Performance Note**: iOS 18's Metal pipeline handles 3D efficiently; keep optional.

### Implementation Considerations

- **State Management**: Leverage SwiftUI's state management system (`@State`, `@Binding`, `@ObservedObject`) to trigger animations in response to state changes.

- **Performance Testing**: Regularly test animations on various devices to ensure they perform well and do not hinder the app's responsiveness.

- **Accessibility**: Ensure that animations do not negatively impact users with motion sensitivities. Provide options to reduce or disable animations as needed.


These align with the best practices from sources like thermal-core.com and medium.com, emphasizing subtlety and performance.

## 📖 Additional Resources

- [SwiftUI Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/overview/design-principles/)
- [Accessibility Guidelines](https://developer.apple.com/accessibility/)
- [Platform Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [WCAG Color Contrast Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)

