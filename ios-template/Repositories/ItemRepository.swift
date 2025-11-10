//
//  ItemRepository.swift
//  ios-template
//
//  Generic repository for loading and managing items.
//

import Foundation

@globalActor
public actor ItemsActor {
    public static let shared = ItemsActor()
}

/// Protocol defining the contract for item data operations
///
/// Implement this protocol to provide different data sources (API, local, mock).
public protocol ItemRepositoryProtocol: Sendable {
    /// Fetch all items
    func fetchItems() async throws -> [TemplateItem]

    /// Fetch a specific item by ID
    func fetchItem(id: String) async throws -> TemplateItem

    /// Search items by query
    func searchItems(query: String) async throws -> [TemplateItem]

    /// Filter items by category
    func fetchItems(category: String) async throws -> [TemplateItem]
}

/// Default implementation of ItemRepository
///
/// Remote + local pattern:
/// - Remote: fetch from API via NetworkClientProtocol
/// - Local: in-memory cache owned by this actor
public actor ItemRepository: ItemRepositoryProtocol {

    // MARK: - Private Properties

    private let networkClient: NetworkClientProtocol
    private var cachedItems: [TemplateItem] = []
    private var lastFetchDate: Date?
    private let cacheExpirationInterval: TimeInterval = 300  // 5 minutes

    // MARK: - Initialization

    public init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    // MARK: - Public Methods

    public func fetchItems() async throws -> [TemplateItem] {
        // Serve from cache if fresh
        if let lastFetch = lastFetchDate,
           Date().timeIntervalSince(lastFetch) < cacheExpirationInterval,
           !cachedItems.isEmpty {
            return cachedItems
        }

        // Remote fetch; adapt path to your API ("items" is a placeholder)
        let items: [TemplateItem]
        do {
            items = try await networkClient.get("items", base: .default, query: nil)
        } catch {
            // On failure, fall back to stale cache if available
            if !cachedItems.isEmpty {
                return cachedItems
            }
            throw error
        }

        cachedItems = items
        lastFetchDate = Date()
        return items
    }

    public func fetchItem(id: String) async throws -> TemplateItem {
        let items = try await fetchItems()

        guard let item = items.first(where: { $0.id == id }) else {
            throw AppError.itemNotFound(id: id)
        }

        return item
    }

    public func searchItems(query: String) async throws -> [TemplateItem] {
        let items = try await fetchItems()
        let lowercasedQuery = query.lowercased()

        return items.filter { item in
            item.title.lowercased().contains(lowercasedQuery)
                || item.summary.lowercased().contains(lowercasedQuery)
                || item.creator.lowercased().contains(lowercasedQuery)
        }
    }

    public func fetchItems(category: String) async throws -> [TemplateItem] {
        let items = try await fetchItems()

        return items.filter { item in
            item.primaryCategory == category || item.categories.contains(category)
        }
    }
}
