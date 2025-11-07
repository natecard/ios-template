//
//  ModernItemCard.swift
//  Template Repository
//
//  Modern card component for displaying generic items with actions.
//  Generalized from ModernItemCard.
//

import SwiftUI

/// Modern card component for displaying any item conforming to GenericItem
///
/// Features:
/// - Hover effects with optional parallax
/// - Favorite and share actions
/// - Category/tag display
/// - Metadata badges
/// - Selection state
/// - Motion-aware animations
///
/// Example usage:
/// ```swift
/// ModernItemCard(
///     item: item,
///     metadata: ItemMetadata(item),
///     isSelected: false,
///     showActions: true
/// ) {
///     print("Card tapped")
/// } onFavorite: {
///     print("Favorite tapped")
/// } onShare: {
///     print("Share tapped")
/// }
/// ```
struct ModernItemCard<Item: GenericItem, DataManager: GenericDataManager>: View
where DataManager.Item == Item {
    let item: Item
    let metadata: ItemCardMetadata
    let isSelected: Bool
    let showActions: Bool
    let interactionStyle: InteractionStyle
    let accessory: AnyView?
    let onTap: () -> Void
    let onFavorite: (() -> Void)?
    let onShare: (() -> Void)?

    @Environment(\.motionStyle) private var motionStyle
    @Environment(DataManager.self) private var dataManager
    @State private var isHovered = false

    private var hoverScale: CGFloat {
        guard motionStyle.motionEnabled else { return 1 }
        return 1 + motionStyle.amplitude(0.01)
    }

    init(
        item: Item,
        metadata: ItemCardMetadata,
        isSelected: Bool = false,
        showActions: Bool = true,
        interactionStyle: InteractionStyle = .button,
        accessory: AnyView? = nil,
        onTap: @escaping () -> Void = {},
        onFavorite: (() -> Void)? = nil,
        onShare: (() -> Void)? = nil
    ) {
        self.item = item
        self.metadata = metadata
        self.isSelected = isSelected
        self.showActions = showActions
        self.interactionStyle = interactionStyle
        self.accessory = accessory
        self.onTap = onTap
        self.onFavorite = onFavorite
        self.onShare = onShare
    }

    enum InteractionStyle { case button, staticLabel }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content
            let content = VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Header with title and actions
                HStack(alignment: .top) {
                    // Title
                    Text(item.title)
                        .font(DesignSystem.Typography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Action buttons
                    if let accessory = accessory {
                        accessory
                    } else if showActions {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            if let onFavorite = onFavorite {
                                FavoriteCornerButton(
                                    isFavorite: dataManager.isFavorite(item),
                                    onToggle: onFavorite
                                )
                            }

                            if let onShare = onShare {
                                IconButton(
                                    icon: "square.and.arrow.up",
                                    size: .small,
                                    style: .ghost
                                ) {
                                    onShare()
                                }
                            }
                        }
                        .opacity(isHovered ? 1.0 : 0.0)
                        .animation(DesignSystem.Animation.fast, value: isHovered)
                    }
                }

                // Creator and date
                HStack {
                    Text(item.creator)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(1)

                    Spacer()

                    Text(item.createdDate, style: .date)
                        .font(DesignSystem.Typography.labelSmall)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }

                // Summary/Abstract
                Text(item.summary)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)

                // Categories and metadata
                VStack(spacing: DesignSystem.Spacing.sm) {
                    // Category tags
                    if !metadata.displayCategories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                ForEach(Array(metadata.displayCategories.prefix(3)), id: \.self) { category in
                                    Text(category)
                                        .font(DesignSystem.Typography.labelSmall)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                        .padding(.horizontal, DesignSystem.Spacing.sm)
                                        .padding(.vertical, DesignSystem.Spacing.xs)
                                        .background(DesignSystem.Colors.primary.opacity(0.1))
                                        .designCornerRadius(DesignSystem.BorderRadius.sm)
                                }

                                if metadata.displayCategories.count > 3 {
                                    Text("+\(metadata.displayCategories.count - 3)")
                                        .font(DesignSystem.Typography.labelSmall)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                        .padding(.horizontal, DesignSystem.Spacing.sm)
                                        .padding(.vertical, DesignSystem.Spacing.xs)
                                        .background(DesignSystem.Colors.neutralLight.opacity(0.3))
                                        .designCornerRadius(DesignSystem.BorderRadius.sm)
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.xs)
                        }
                    }

                    // Footer info
                    HStack {
                        // Primary badge
                        if let badgeText = metadata.badgeText {
                            Text(badgeText.uppercased())
                                .font(DesignSystem.Typography.labelSmall)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.white)
                                .padding(.horizontal, DesignSystem.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(metadata.badgeColor ?? DesignSystem.Colors.success)
                                .designCornerRadius(DesignSystem.BorderRadius.sm)
                        }

                        Spacer()

                        // Attachment availability
                        if item.hasAttachment, let attachmentLabel = metadata.attachmentLabel {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: metadata.attachmentIcon ?? "doc.text.fill")
                                    .foregroundColor(DesignSystem.Colors.primary)
                                Text(attachmentLabel)
                                    .font(DesignSystem.Typography.labelSmall)
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)

            if interactionStyle == .button {
                Button(action: onTap) { content }
                    .buttonStyle(PressableButtonStyle())
            } else {
                content
                    .contentShape(Rectangle())
            }
        }
        .liquidGlass(.elevated)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.lg)
                .stroke(
                    isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.clear,
                    lineWidth: isSelected ? 2 : 0
                )
        )
        .scaleEffect(isSelected ? 1.02 : (isHovered ? hoverScale : 1.0))
        .onHover { hovering in
            withAnimation(motionStyle.microSpring) {
                isHovered = hovering
            }
        }
        .animation(DesignSystem.Animation.fast, value: isSelected)
        .cardParallax(id: item.id)
    }
}

/// Metadata configuration for item card display
///
/// Provides display customization for the ModernItemCard component.
public struct ItemCardMetadata {
    /// Categories to display as tags (will show first 3 with overflow indicator)
    public let displayCategories: [String]

    /// Text to display in the primary badge (e.g., "CS", "PHYSICS")
    public let badgeText: String?

    /// Color for the primary badge
    public let badgeColor: Color?

    /// Label for attachment indicator (e.g., "PDF", "EPUB")
    public let attachmentLabel: String?

    /// Icon for attachment indicator
    public let attachmentIcon: String?

    public init(
        displayCategories: [String] = [],
        badgeText: String? = nil,
        badgeColor: Color? = nil,
        attachmentLabel: String? = nil,
        attachmentIcon: String? = nil
    ) {
        self.displayCategories = displayCategories
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.attachmentLabel = attachmentLabel
        self.attachmentIcon = attachmentIcon
    }
}
