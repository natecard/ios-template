//
//  ItemsListViewModel.swift
//  ios-template
//
//  ViewModel for the items list screen.
//

import Foundation
import Observation

/// ViewModel for the items list screen
///
/// Manages item loading, searching, and filtering.
@Observable
public final class ItemsListViewModel {

    // MARK: - Published State

    public var items: [TemplateItem] = []
    public var isLoading = false
    public var errorMessage: String?
    public var selectedCategory: String?

    // MARK: - Dependencies

    private let repository: ItemRepository
    private let dataManager: ItemDataManager

    // MARK: - Computed Properties

    public var filteredItems: [TemplateItem] {
        guard let category = selectedCategory else {
            return items
        }

        return items.filter { item in
            item.primaryCategory == category || item.categories.contains(category)
        }
    }

    public var availableCategories: [String] {
        let allCategories = items.flatMap { item in
            [item.primaryCategory] + item.categories
        }
        return Array(Set(allCategories)).sorted()
    }

    // MARK: - Initialization

    public init(repository: ItemRepository, dataManager: ItemDataManager) {
        self.repository = repository
        self.dataManager = dataManager
    }

    // MARK: - Actions

    /// Load items from repository
    public func loadItems() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            items = try await repository.fetchItems()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Reload items (for pull-to-refresh)
    public func reload() async {
        await loadItems()
    }

    /// Select a category filter
    public func selectCategory(_ category: String?) {
        selectedCategory = category
    }

    /// Toggle favorite status for an item
    public func toggleFavorite(_ item: TemplateItem) {
        dataManager.toggleFavorite(item)
    }

    /// Check if an item is favorited
    public func isFavorite(_ item: TemplateItem) -> Bool {
        dataManager.isFavorite(item)
    }
}
