//
//  ItemsListView.swift
//  ios-template
//
//
//  Main items list screen view displaying generic content.

import SwiftUI

/// Items List screen view
///
/// Displays a list of items with search, filtering, and favorite capabilities.
public struct ItemsListView: View {
    @State private var viewModel: ItemsListViewModel
    @State private var showingCategoryFilter = false

    public init(viewModel: ItemsListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Category filter
                    if !viewModel.availableCategories.isEmpty {
                        categoryFilterView
                    }

                    // Item list
                    ModernItemListView(
                        items: viewModel.filteredItems,
                        metadata: { item in
                            ItemCardMetadata(
                                displayCategories: item.categories,
                                badgeText: item.primaryCategory,
                                badgeColor: categoryColor(
                                    for: item.primaryCategory
                                ),
                                attachmentLabel: item.hasAttachment
                                    ? "PDF" : nil,
                                attachmentIcon: "doc.fill"
                            )
                        },
                        isLoading: viewModel.isLoading,
                        errorMessage: viewModel.errorMessage,
                        emptyStateConfig: EmptyStateConfig(
                            loadingMessage: "Loading items...",
                            errorTitle: "Unable to Load Items",
                            emptyIcon: "doc.text",
                            emptyTitle: "No Items",
                            emptyMessage: "Start browsing to discover items",
                            emptyActionTitle: nil,
                            emptyAction: nil
                        ),
                        onItemTap: { item in
                            // TODO: Navigate to detail view
                            print("Tapped item: \(item.title)")
                        },
                        onFavorite: { item in
                            viewModel.toggleFavorite(item)
                        },
                        onShare: { item in
                            // TODO: Implement share
                            print("Share item: \(item.title)")
                        },
                        onRetry: {
                            Task {
                                await viewModel.reload()
                            }
                        }
                    )
                }
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCategoryFilter.toggle()
                    } label: {
                        AnimatedSymbol(
                            "line.3.horizontal.decrease.circle",
                            effect: .scale,
                            trigger: showingCategoryFilter
                        )
                        .font(.system(size: 20))  // iOS 26: Larger toolbar icon
                    }
                    .accessibilityLabel("Filter by category")
                    .accessibilityHint("Shows category filter options")
                }
            }
            .sheet(isPresented: $showingCategoryFilter) {
                CategoryFilterSheet(
                    categories: viewModel.availableCategories,
                    selectedCategory: viewModel.selectedCategory,
                    onSelect: { category in
                        viewModel.selectCategory(category)
                        showingCategoryFilter = false
                    }
                )
                .presentationBackground(.regularMaterial)  // iOS 26: Liquid Glass sheet background
                .presentationCornerRadius(DesignSystem.BorderRadius.xl)  // iOS 26: Larger corner radius
            }
            .task {
                await viewModel.loadItems()
            }
            .refreshable {
                await viewModel.reload()
            }
        }
    }

    // MARK: - Subviews

    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                // All categories chip
                CategoryChip(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil,
                    action: {
                        viewModel.selectCategory(nil)
                    }
                )

                // Individual categories
                ForEach(viewModel.availableCategories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: viewModel.selectedCategory == category,
                        action: {
                            viewModel.selectCategory(category)
                        }
                    )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)  // iOS 26: Increased horizontal padding
            .padding(.vertical, DesignSystem.Spacing.sm)    // iOS 26: Added vertical padding
        }
    }

    // MARK: - Helpers

    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Development":
            return DesignSystem.Colors.primary
        case "Architecture":
            return DesignSystem.Colors.success
        case "User Experience":
            return DesignSystem.Colors.warning
        default:
            return DesignSystem.Colors.neutral
        }
    }
}

// MARK: - Category Chip Component

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        IconButton(icon: title, action: action)
    }
}
// MARK: - Category Filter Sheet

private struct CategoryFilterSheet: View {
    let categories: [String]
    let selectedCategory: String?
    let onSelect: (String?) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Categories") {
                    Button {
                        onSelect(nil)
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                            Text("All Items")
                            Spacer()
                            if selectedCategory == nil {
                                AnimatedSymbol.favorite("checkmark", isFavorite: true)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .font(.system(size: 16))  // iOS 26: Larger checkmark
                            }
                        }
                        .padding(.vertical, DesignSystem.Spacing.xxs)  // iOS 26: Better touch target
                    }

                    ForEach(categories, id: \.self) { category in
                        Button {
                            onSelect(category)
                        } label: {
                            HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                                Text(category)
                                Spacer()
                                if selectedCategory == category {
                                    AnimatedSymbol.favorite("checkmark", isFavorite: true)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                        .font(.system(size: 16))  // iOS 26: Larger checkmark
                                }
                            }
                            .padding(.vertical, DesignSystem.Spacing.xxs)  // iOS 26: Better touch target
                        }
                    }
                }
            }
            .navigationTitle("Filter by Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    ItemsListView(
        viewModel: ItemsListViewModel(
            repository: ItemRepository(),
            dataManager: ItemDataManager(
                persistenceService: try! JSONPersistenceService()
            )
        )
    )
}
