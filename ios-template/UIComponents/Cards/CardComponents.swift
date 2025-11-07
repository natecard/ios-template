//
//  CardComponents.swift
//  ios-template
//
// Card components for displaying various types of information.
//

import SwiftUI

// MARK: - Base Card
struct BaseCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadow: Shadow?
    let backgroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat

    init(
        padding: CGFloat = DesignSystem.Spacing.md,
        cornerRadius: CGFloat = DesignSystem.BorderRadius.md,
        shadow: Shadow? = DesignSystem.Shadows.small,
        backgroundColor: Color = DesignSystem.Colors.surface,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .designCornerRadius(cornerRadius)
            .overlay(
                Group {
                    if let borderColor = borderColor {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
                }
            )
            .if(shadow != nil) { view in
                view.designShadow(shadow!)
            }
    }
}

// MARK: - Interactive Card
struct InteractiveCard<Content: View>: View {
    @Environment(\.motionStyle) private var motionStyle

    let content: Content
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isHovered = false
    private let parallaxID = UUID()

    init(
        isSelected: Bool = false,
        onTap: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.onTap = onTap
        self.content = content()
    }

    private var hoverScale: CGFloat {
        guard motionStyle.motionEnabled else { return 1 }
        return 1 + motionStyle.amplitude(0.01)
    }

    var body: some View {
        BaseCard(
            backgroundColor: isSelected
                ? DesignSystem.Colors.primary.opacity(0.1) : DesignSystem.Colors.surface,
            borderColor: isSelected ? DesignSystem.Colors.primary : nil,
            borderWidth: isSelected ? 2 : 0
        ) {
            PressableRow {
                content
            }
        }
        .onTapGesture { onTap() }
        .scaleEffect(isSelected ? 1.02 : (isHovered ? hoverScale : 1.0))
        .animation(DesignSystem.Animation.fast, value: isSelected)
        .cardParallax(id: parallaxID)
        .onHover { hovering in
            withAnimation(motionStyle.microSpring) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Item Card
struct ItemCard: View {
    @Environment(\.motionStyle) private var motionStyle

    let title: String
    let subtitle: String?
    let description: String?
    let metadata: [String]
    let isSelected: Bool
    let onTap: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        metadata: [String] = [],
        isSelected: Bool = false,
        onTap: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.metadata = metadata
        self.isSelected = isSelected
        self.onTap = onTap
    }

    var body: some View {
        InteractiveCard(isSelected: isSelected, onTap: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Title
                Text(title)
                    .font(DesignSystem.Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Subtitle
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                }

                // Description
                if let description = description {
                    Text(description)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }

                // Metadata tags
                if !metadata.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(metadata, id: \.self) { tag in
                                Text(tag)
                                    .font(DesignSystem.Typography.labelSmall)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .padding(.horizontal, DesignSystem.Spacing.sm)
                                    .padding(.vertical, DesignSystem.Spacing.xs)
                                    .background(DesignSystem.Colors.primary.opacity(0.1))
                                    .designCornerRadius(DesignSystem.BorderRadius.sm)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                    }
                }
            }
        }
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let message: String
    let style: InfoCardStyle

    enum InfoCardStyle {
        case info, success, warning, error

        var iconColor: Color {
            switch self {
            case .info: return DesignSystem.Colors.info
            case .success: return DesignSystem.Colors.success
            case .warning: return DesignSystem.Colors.warning
            case .error: return DesignSystem.Colors.error
            }
        }

        var backgroundColor: Color {
            switch self {
            case .info: return DesignSystem.Colors.info.opacity(0.1)
            case .success: return DesignSystem.Colors.success.opacity(0.1)
            case .warning: return DesignSystem.Colors.warning.opacity(0.1)
            case .error: return DesignSystem.Colors.error.opacity(0.1)
            }
        }
    }

    init(
        icon: String,
        title: String,
        message: String,
        style: InfoCardStyle = .info
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.style = style
    }

    var body: some View {
        BaseCard(
            backgroundColor: style.backgroundColor,
            borderColor: style.iconColor.opacity(0.3),
            borderWidth: 1
        ) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                AnimatedSymbol(icon, effect: .pulse, isActive: true)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(style.iconColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.titleSmall)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text(message)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Empty State Card
struct EmptyStateCard: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {  // iOS 26: Increased spacing
            AnimatedSymbol(icon, effect: .appear, trigger: true)
                .font(.system(size: 56))  // iOS 26: Larger icon
                .foregroundColor(DesignSystem.Colors.textTertiary)

            VStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                Text(title)
                    .font(DesignSystem.Typography.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(actionTitle, icon: "plus", action: action)
            }
        }
        .padding(DesignSystem.Spacing.xxl)  // iOS 26: Increased padding
        .liquidGlass(.base)  // iOS 26: Liquid Glass effect
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.lg))
    }
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview
#if DEBUG
    struct CardComponents_Previews: PreviewProvider {
        static var previews: some View {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    ItemCard(
                        title: "Sample Item Title",
                        subtitle: "Author Name",
                        description:
                            "This is a sample description of the item that demonstrates the card component with various content.",
                        metadata: ["Computer Science", "AI", "Machine Learning"],
                        isSelected: true
                    ) {}

                    InfoCard(
                        icon: "info.circle",
                        title: "Information",
                        message: "This is an informational message that provides context to the user."
                    )

                    EmptyStateCard(
                        icon: "doc.text",
                        title: "No Items Found",
                        message:
                            "Start by searching for items or browse trending papers to discover new content.",
                        actionTitle: "Search Items"
                    ) {}
                }
                .padding()
            }
            .background(DesignSystem.Colors.background)
        }
    }
#endif
