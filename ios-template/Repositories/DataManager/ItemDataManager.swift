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
@MainActor
@Observable
public final class ItemDataManager: GenericDataManager {
    public typealias Item = TemplateItem
    public typealias Collection = TemplateItemCollection

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
        Task { try? await persistenceService.saveFavorites(favoriteItems) }
    }

    public func removeFavorite(_ item: Item) {
        favoriteItems.removeAll(where: { $0.id == item.id })
        Task { try? await persistenceService.saveFavorites(favoriteItems) }
    }

    /// Remove all user collections managed by this data manager.
    public func removeAllCollections() {
        userCollections.removeAll(keepingCapacity: false)
        Task { try? await persistenceService.saveCollections(userCollections) }
    }
}
