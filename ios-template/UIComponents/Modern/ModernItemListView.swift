//
//  ModernItemListView.swift
//  Template Repository
//
//  Modern list component for displaying collections of generic items.
//  Generalized from ModernItemListView.
//

import SwiftUI

/// Modern list view for displaying collections of items
///
/// Features:
/// - Loading state with skeletons
/// - Error state with retry
/// - Empty state
/// - Staggered animations
/// - Pull-to-refresh support (when used in ScrollView)
///
/// Example usage:
/// ```swift
/// ModernItemListView(
///     items: items,
///     metadata: { ItemMetadata($0) },
///     isLoading: viewModel.isLoading,
///     errorMessage: viewModel.errorMessage,
///     onItemTap: { item in
///         viewModel.selectItem(item)
///     },
///     onFavorite: { item in
///         dataManager.toggleFavorite(item)
///     },
///     onShare: { item in
///         shareItem(item)
///     },
///     onRetry: {
///         viewModel.reload()
///     }
/// )
/// ```
public struct ModernItemListView: View {
    let items: [TemplateItem]
    let metadata: (TemplateItem) -> ItemCardMetadata
    let isLoading: Bool
    let errorMessage: String?
    let emptyStateConfig: EmptyStateConfig
    let onItemTap: (TemplateItem) -> Void
    let onFavorite: ((TemplateItem) -> Void)?
    let onShare: ((TemplateItem) -> Void)?
    let onRetry: (() -> Void)?

    @State private var animatedIDs: Set<String> = []

    init(
        items: [TemplateItem],
        metadata: @escaping (TemplateItem) -> ItemCardMetadata,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        emptyStateConfig: EmptyStateConfig = .default,
        onItemTap: @escaping (TemplateItem) -> Void,
        onFavorite: ((TemplateItem) -> Void)? = nil,
        onShare: ((TemplateItem) -> Void)? = nil,
        onRetry: (() -> Void)? = nil
    ) {
        self.items = items
        self.metadata = metadata
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.emptyStateConfig = emptyStateConfig
        self.onItemTap = onItemTap
        self.onFavorite = onFavorite
        self.onShare = onShare
        self.onRetry = onRetry
    }

    public var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if items.isEmpty {
                emptyStateView
            } else {
                itemList
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            LoadingView(message: emptyStateConfig.loadingMessage, style: .large)

            // Show skeleton loading for better UX
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(0..<5, id: \.self) { _ in
                    ItemSkeleton()
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
    }

    private func errorView(message: String) -> some View {
        EmptyStateCard(
            icon: "exclamationmark.triangle",
            title: emptyStateConfig.errorTitle,
            message: message,
            actionTitle: "Try Again"
        ) {
            onRetry?()
        }
        .padding(DesignSystem.Spacing.lg)
    }

    private var emptyStateView: some View {
        EmptyStateCard(
            icon: emptyStateConfig.emptyIcon,
            title: emptyStateConfig.emptyTitle,
            message: emptyStateConfig.emptyMessage,
            actionTitle: emptyStateConfig.emptyActionTitle
        ) {
            emptyStateConfig.emptyAction?()
        }
        .padding(DesignSystem.Spacing.lg)
    }

    private var itemList: some View {
        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            itemRow(for: item, at: index)
        }
        .padding(DesignSystem.Spacing.md)
        .animation(DesignSystem.Animation.normal, value: items.count)
        .onChange(of: items.map(\.id)) { _, newIDs in
            animatedIDs = animatedIDs.intersection(Set(newIDs))
        }
    }
    @ViewBuilder
    private func itemRow(for item: TemplateItem, at index: Int) -> some View {
        let card = ModernItemCard<TemplateItem, ItemDataManager>(
            item: item,
            metadata: metadata(item),
            isSelected: false,
            showActions: true
        ) {
            onItemTap(item)
        } onFavorite: {
            onFavorite?(item)
        } onShare: {
            onShare?(item)
        }

        card
            .listAppear(
                index: index,
                id: item.id,
                animatedIDs: $animatedIDs
            )
            .transition(.opacity.combined(with: .scale))
    }
}

/// Configuration for empty state display
public struct EmptyStateConfig {
    public let loadingMessage: String
    public let errorTitle: String
    public let emptyIcon: String
    public let emptyTitle: String
    public let emptyMessage: String
    public let emptyActionTitle: String?
    public let emptyAction: (() -> Void)?

    public init(
        loadingMessage: String = "Loading items...",
        errorTitle: String = "Unable to Load Items",
        emptyIcon: String = "tray",
        emptyTitle: String = "No Items Found",
        emptyMessage: String = "There are no items to display.",
        emptyActionTitle: String? = nil,
        emptyAction: (() -> Void)? = nil
    ) {
        self.loadingMessage = loadingMessage
        self.errorTitle = errorTitle
        self.emptyIcon = emptyIcon
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.emptyActionTitle = emptyActionTitle
        self.emptyAction = emptyAction
    }

    /// Default empty state configuration
    public static let `default` = EmptyStateConfig()
}
