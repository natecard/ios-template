//
//  SearchViewModel.swift
//  ios-template
//
//  ViewModel for search screen.
//

import Foundation
import Observation

/// ViewModel for the search screen
///
/// Manages item search functionality.
@MainActor
@Observable
public final class SearchViewModel {

    // MARK: - Published State

    public var searchQuery = ""
    public var searchResults: [TemplateItem] = []
    public var isSearching = false
    public var errorMessage: String?
    public var recentSearches: [String] = []

    // MARK: - Dependencies

    private let repository: ItemRepository
    private let dataManager: ItemDataManager

    // MARK: - Computed Properties

    public var hasResults: Bool {
        !searchResults.isEmpty
    }

    public var showingResults: Bool {
        !searchQuery.isEmpty && !isSearching
    }

    // MARK: - Initialization

    public init(repository: ItemRepository, dataManager: ItemDataManager) {
        self.repository = repository
        self.dataManager = dataManager
    }

    // MARK: - Actions

    /// Perform search
    public func search() async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        errorMessage = nil

        defer { isSearching = false }

        do {
            searchResults = try await repository.searchItems(query: searchQuery)
            addToRecentSearches(searchQuery)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Clear search
    public func clearSearch() {
        searchQuery = ""
        searchResults = []
        errorMessage = nil
    }

    /// Select a recent search
    public func selectRecentSearch(_ query: String) {
        searchQuery = query
        Task {
            await search()
        }
    }

    /// Clear recent searches
    public func clearRecentSearches() {
        recentSearches = []
    }

    /// Toggle favorite
    public func toggleFavorite(_ item: TemplateItem) {
        dataManager.toggleFavorite(item)
    }

    /// Check if favorited
    public func isFavorite(_ item: TemplateItem) -> Bool {
        dataManager.isFavorite(item)
    }

    // MARK: - Private Helpers

    private func addToRecentSearches(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Remove if already exists
        recentSearches.removeAll { $0 == trimmed }

        // Add to front
        recentSearches.insert(trimmed, at: 0)

        // Keep only last 10
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
    }
}
