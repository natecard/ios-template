//
//  SearchView.swift
//  ios-template
//
//  Search screen view.
//

import SwiftUI

/// Search screen view
///
/// Allows users to search items with recent searches.
public struct SearchView: View {
    @State private var viewModel: SearchViewModel

    public init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                ModernSearchBar(
                    text: $viewModel.searchQuery,
                    placeholder: "Search items...",
                    showSuggestions: false,
                    suggestions: [],
                    onSearch: {
                        Task {
                            await viewModel.search()
                        }
                    }
                )
                .padding(DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.xxs)  // iOS 26: Tighter top spacing

                // Content
                ScrollView {
                    if viewModel.showingResults {
                        resultsView
                    } else if !viewModel.recentSearches.isEmpty {
                        recentSearchesView
                    } else {
                        emptyStateView
                    }
                }
            }
            .navigationTitle("Search")
        }
    }

    // MARK: - Subviews

    private var resultsView: some View {
        ModernItemListView(
            items: viewModel.searchResults,
            metadata: { item in
                ItemCardMetadata(
                    displayCategories: item.categories,
                    badgeText: item.primaryCategory,
                    badgeColor: DesignSystem.Colors.primary,
                    attachmentLabel: item.hasAttachment ? "PDF" : nil,
                    attachmentIcon: "doc.fill"
                )
            },
            isLoading: viewModel.isSearching,
            errorMessage: viewModel.errorMessage,
            emptyStateConfig: EmptyStateConfig(
                loadingMessage: "Searching...",
                errorTitle: "Search Failed",
                emptyIcon: "magnifyingglass",
                emptyTitle: "No Results",
                emptyMessage: "No items found for '\(viewModel.searchQuery)'",
                emptyActionTitle: nil,
                emptyAction: nil
            ),
            onItemTap: { item in
                // TODO: Navigate to detail
                print("Tapped: \(item.title)")
            },
            onFavorite: { item in
                viewModel.toggleFavorite(item)
            },
            onShare: { item in
                // TODO: Implement share
                print("Share: \(item.title)")
            }
        )
    }

    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Recent Searches")
                    .font(DesignSystem.Typography.titleMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                Button("Clear") {
                    viewModel.clearRecentSearches()
                }
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.primary)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.lg)  // iOS 26: Increased spacing

            ForEach(viewModel.recentSearches, id: \.self) { query in
                Button {
                    viewModel.selectRecentSearch(query)
                } label: {
                    HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                        AnimatedSymbol("clock.arrow.circlepath")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .font(.system(size: 16))

                        Text(query)
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        Spacer()

                        AnimatedSymbol("chevron.right")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .font(.caption)
                    }
                    .padding(.all, DesignSystem.Spacing.md)  // iOS 26: Increased touch target
                    .liquidGlass(.base)  // iOS 26: Liquid Glass effect
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.md))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, DesignSystem.Spacing.sm)

                if query != viewModel.recentSearches.last {
                    Divider()
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {  // iOS 26: Increased spacing
            AnimatedSymbol("magnifyingglass", effect: .appear, trigger: true)
                .font(.system(size: 64))  // iOS 26: Larger icon
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .padding(.top, 60)

            VStack(spacing: DesignSystem.Spacing.sm) {  // iOS 26: Better text grouping
                Text("Search for Items")
                    .font(DesignSystem.Typography.titleMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("Enter keywords to find items")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DesignSystem.Spacing.xl)  // iOS 26: Increased padding
    }
}

// MARK: - Previews

#Preview {
    SearchView(
        viewModel: SearchViewModel(
            repository: ItemRepository(),
            dataManager: ItemDataManager(
                persistenceService: try! JSONPersistenceService()
            )
        )
    )
}
