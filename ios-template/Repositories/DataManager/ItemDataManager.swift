//
//  ItemDataManager.swift
//  ios-template
//
//  Generic data manager for items.
//

import Foundation
import Observation

/// Main data manager for items, favorites, and collections
///
/// This class manages the in-memory state and coordinates with persistence services.
///
/// Example usage:
/// ```swift
/// @State private var dataManager = ItemDataManager(persistenceService: persistence)
///
/// dataManager.toggleFavorite(item)
/// if dataManager.isFavorite(item) {
///     print("Item is favorited")
/// }
/// ```
@Observable
public final class ItemDataManager: GenericDataManager {
    public typealias Collection = TemplateItemCollection
    public typealias Item = TemplateItem

    public var items: [Item] = []
    public var favoriteItems: [Item] = []
    public var userCollections: [Collection] = []

    private let persistenceService: any PersistenceServiceProtocol<Item, Collection>

    public init(persistenceService: any PersistenceServiceProtocol<Item, Collection>) {
        self.persistenceService = persistenceService
    }

    public func isFavorite(_ item: Item) -> Bool {
        favoriteItems.contains(where: { $0.id == item.id })
    }

    public func toggleFavorite(_ item: Item) {
        if isFavorite(item) {
            removeFavorite(item)
        } else {
            addFavorite(item)
        }
    }

    public func addFavorite(_ item: Item) {
        guard !isFavorite(item) else { return }
        favoriteItems.append(item)
        let favoritesSnapshot = favoriteItems
        let service = persistenceService
        Task {
            try? await service.saveFavorites(favoritesSnapshot)
        }
    }

    public func removeFavorite(_ item: Item) {
        favoriteItems.removeAll(where: { $0.id == item.id })
        let favoritesSnapshot = favoriteItems
        let service = persistenceService
        Task {
            try? await service.saveFavorites(favoritesSnapshot)
        }
    }

    public func removeAllCollections() {
        userCollections.removeAll(keepingCapacity: false)

        let collectionsSnapshot = userCollections
        let service = persistenceService

        Task {
            try? await service.saveCollections(collectionsSnapshot)
        }
    }
}
