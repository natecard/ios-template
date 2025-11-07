//
//  ButtonComponents.swift
//  ios-template
//
// Various button components with different styles and behaviors.
//

import SwiftUI

// MARK: - Button Size Definition
enum ButtonSize {
    case small, medium, large

    var verticalPadding: CGFloat {
        switch self {
        case .small: return DesignSystem.Spacing.xs
        case .medium: return DesignSystem.Spacing.sm
        case .large: return DesignSystem.Spacing.md
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return DesignSystem.Spacing.md
        case .medium: return DesignSystem.Spacing.lg
        case .large: return DesignSystem.Spacing.xl
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 20
        }
    }

    var font: Font {
        switch self {
        case .small: return DesignSystem.Typography.labelSmall
        case .medium: return DesignSystem.Typography.labelMedium
        case .large: return DesignSystem.Typography.labelLarge
        }
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isDisabled: Bool
    let size: ButtonSize
    let isFullWidth: Bool
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.isFullWidth = isFullWidth
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if isLoading {
                    AnimatedSymbol.loading("arrow.trianglehead.2.clockwise.rotate.90", isLoading: true)
                        .font(.system(size: size.iconSize, weight: .medium))
                } else if let icon = icon {
                    AnimatedSymbol(icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }

                Text(title)
                    .font(size.font)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                isDisabled ? DesignSystem.Colors.secondaryLight : DesignSystem.Colors.primary
            )
            .foregroundColor(DesignSystem.Colors.white)
            .designCornerRadius(DesignSystem.BorderRadius.md)
            .designShadow(DesignSystem.Shadows.small)
        }
        .disabled(isDisabled || isLoading)
        .scaleEffect(isDisabled ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.fast, value: isDisabled)
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let size: ButtonSize
    let isDisabled: Bool
    let isFullWidth: Bool
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        isDisabled: Bool = false,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.size = size
        self.isDisabled = isDisabled
        self.isFullWidth = isFullWidth
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }

                Text(title)
                    .font(size.font)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(DesignSystem.Colors.surface)
            .foregroundColor(DesignSystem.Colors.primary)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.md)
                    .stroke(DesignSystem.Colors.primary, lineWidth: 1.5)
            )
            .designCornerRadius(DesignSystem.BorderRadius.md)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .animation(DesignSystem.Animation.fast, value: isDisabled)
    }
}

// MARK: - Ghost Button
struct GhostButton: View {
    let title: String
    let icon: String?
    let size: ButtonSize
    let isDisabled: Bool
    let isFullWidth: Bool
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        size: ButtonSize = .medium,
        isDisabled: Bool = false,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.size = size
        self.isDisabled = isDisabled
        self.isFullWidth = isFullWidth
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    AnimatedSymbol(icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }

                Text(title)
                    .font(size.font)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .foregroundColor(DesignSystem.Colors.primary)
            .background(DesignSystem.Colors.primary.opacity(0.1))
            .designCornerRadius(DesignSystem.BorderRadius.md)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .animation(DesignSystem.Animation.fast, value: isDisabled)
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let size: IconButtonSize
    let style: IconButtonStyle
    let isDisabled: Bool
    let action: () -> Void

    enum IconButtonSize {
        case small, medium, large

        var frameSize: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
    }

    enum IconButtonStyle {
        case primary, secondary, ghost, destructive

        var backgroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.primary
            case .secondary: return DesignSystem.Colors.surface
            case .ghost: return DesignSystem.Colors.primary.opacity(0.1)
            case .destructive: return DesignSystem.Colors.error
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.white
            case .secondary: return DesignSystem.Colors.primary
            case .ghost: return DesignSystem.Colors.primary
            case .destructive: return DesignSystem.Colors.white
            }
        }

        var borderColor: Color? {
            switch self {
            case .secondary: return DesignSystem.Colors.primary
            default: return nil
            }
        }
    }

    init(
        icon: String,
        size: IconButtonSize = .medium,
        style: IconButtonStyle = .primary,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.style = style
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            AnimatedSymbol(icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(style.foregroundColor)
                .frame(width: size.frameSize, height: size.frameSize)
                .background(style.backgroundColor)
                .overlay(
                    Group {
                        if let borderColor = style.borderColor {
                            RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.sm)
                                .stroke(borderColor, lineWidth: 1.5)
                        }
                    }
                )
                .designCornerRadius(DesignSystem.BorderRadius.sm)
                .designShadow(DesignSystem.Shadows.small)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(isDisabled ? 0.95 : 1.0)
        .animation(DesignSystem.Animation.fast, value: isDisabled)
    }
}

// MARK: - Favorite Button with Animated Feedback
struct FavoriteCornerButton: View {
    let isFavorite: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(DesignSystem.Animation.spring) {
                onToggle()
            }
            // Accessibility announcement
            #if os(iOS)
            Task { @MainActor in
                UIAccessibility.post(
                    notification: .announcement,
                    argument: isFavorite ? "Removed from favorites" : "Added to favorites"
                )
            }
            #endif
        }) {
            AnimatedSymbol.favorite(
                isFavorite ? "heart.fill" : "heart",
                isFavorite: isFavorite
            )
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(isFavorite ? DesignSystem.Colors.error : DesignSystem.Colors.primary)
            .frame(width: 44, height: 44)  // iOS 26: Ensure minimum 44pt touch target
            .background(DesignSystem.Colors.surface)
            .designCornerRadius(DesignSystem.BorderRadius.sm)
            .designShadow(DesignSystem.Shadows.small)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
        .accessibilityHint("Double tap to toggle favorite status")
    }
}

// MARK: - Toolbar Icon Button (plain, no background)
struct ToolbarIconButton: View {
    let icon: String
    let size: IconButton.IconButtonSize
    let accessibilityLabel: String
    let action: () -> Void

    init(
        icon: String,
        size: IconButton.IconButtonSize = .medium,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            AnimatedSymbol(icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.accent)
                .frame(width: size.frameSize, height: size.frameSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed.toggle()
            action()
        }) {
            AnimatedSymbol(icon, effect: .scale, trigger: isPressed)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(DesignSystem.Colors.white)
                .frame(width: 56, height: 56)
                .background(DesignSystem.Colors.primary)
                .designCornerRadius(DesignSystem.BorderRadius.full)
                .designShadow(DesignSystem.Shadows.large)
        }
        .scaleEffect(1.0)
        .animation(DesignSystem.Animation.spring, value: true)
    }
}

// MARK: - Button Style Modifiers
struct InteractiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(DesignSystem.Animation.fast, value: configuration.isPressed)
    }
}

// MARK: - Pressable Button Style (micro-lift)
struct PressableButtonStyle: ButtonStyle {
    @Environment(\.motionStyle) private var motionStyle

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(
                configuration.isPressed && motionStyle.motionEnabled
                    ? 1 - motionStyle.amplitude(motionStyle.pressScaleDownMagnitude)
                    : 1
            )
            .offset(
                y: configuration.isPressed && motionStyle.motionEnabled
                    ? motionStyle.amplitude(motionStyle.pressYOffsetPoints)
                    : 0
            )
            .animation(motionStyle.microSpring, value: configuration.isPressed)
    }
}

// MARK: - Preview
#if DEBUG
    struct ButtonComponents_Previews: PreviewProvider {
        static var previews: some View {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Group {
                        Text("Primary Buttons")
                            .font(DesignSystem.Typography.titleMedium)

                        PrimaryButton("Small Primary", icon: "star", size: .small) {}
                        PrimaryButton("Medium Primary", icon: "plus") {}
                        PrimaryButton("Large Primary", icon: "arrow.right", size: .large) {}

                        HStack {
                            PrimaryButton("Compact", icon: "bolt", size: .small, isFullWidth: false) {}
                            Spacer()
                            PrimaryButton("Compact", icon: "bolt", size: .small, isFullWidth: false) {}
                        }
                    }

                    Group {
                        Text("Secondary Buttons")
                            .font(DesignSystem.Typography.titleMedium)

                        SecondaryButton("Small Secondary", icon: "star", size: .small) {}
                        SecondaryButton("Medium Secondary", icon: "plus") {}
                        SecondaryButton("Large Secondary", icon: "arrow.right", size: .large) {}

                        HStack {
                            SecondaryButton("Compact", icon: "bolt", size: .small, isFullWidth: false) {}
                            Spacer()
                            SecondaryButton("Compact", icon: "bolt", size: .small, isFullWidth: false) {}
                        }
                    }

                    Group {
                        Text("Ghost Buttons")
                            .font(DesignSystem.Typography.titleMedium)

                        GhostButton("Small Ghost", icon: "star", size: .small) {}
                        GhostButton("Medium Ghost", icon: "plus") {}
                        GhostButton("Large Ghost", icon: "arrow.right", size: .large) {}

                        HStack {
                            GhostButton("Compact", icon: "bolt", size: .small, isFullWidth: false) {}
                            Spacer()
                            GhostButton("Compact", icon: "bolt", size: .small, isFullWidth: false) {}
                        }
                    }

                    Group {
                        Text("Icon Buttons")
                            .font(DesignSystem.Typography.titleMedium)

                        HStack(spacing: DesignSystem.Spacing.md) {
                            IconButton(icon: "heart", style: .primary) {}
                            IconButton(icon: "star", style: .secondary) {}
                            IconButton(icon: "trash", style: .destructive) {}
                        }
                    }

                    FloatingActionButton(icon: "plus") {}
                }
                .padding()
            }
            .background(DesignSystem.Colors.background)
        }
    }
#endif
