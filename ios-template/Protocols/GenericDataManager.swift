//
//  GenericDataManager.swift
//  ios-template
//
//  Protocol for managing items and collections with favorite support.
//

import Foundation
import Observation

/// Protocol for managing items, favorites, and collections
///
/// Implement this protocol in your data manager to integrate with favorite buttons
/// and collection management UI components.
///
/// Example implementation:
/// ```swift
/// @MainActor
/// @Observable
/// class ItemDataManager: GenericDataManager {
///     typealias Item = Item
///     typealias Collection = ItemCollection
///
///     var items: [Item] = []
///     var favoriteItems: [Item] = []
///     var userCollections: [ItemCollection] = []
///
///     func isFavorite(_ item: Item) -> Bool {
///         favoriteItems.contains(where: { $0.id == item.id })
///     }
///
///     func toggleFavorite(_ item: Item) {
///         if isFavorite(item) {
///             removeFavorite(item)
///         } else {
///             addFavorite(item)
///         }
///     }
///
///     func addFavorite(_ item: Item) {
///         guard !isFavorite(item) else { return }
///         favoriteItems.append(item)
///     }
///
///     func removeFavorite(_ item: Item) {
///         favoriteItems.removeAll(where: { $0.id == item.id })
///     }
/// }
/// ```
public protocol GenericDataManager: AnyObject, Observable {
    associatedtype Item: GenericItem
    associatedtype Collection: GenericCollection

    /// All items managed by this data manager
    var items: [Item] { get set }

    /// Items marked as favorites
    var favoriteItems: [Item] { get set }

    /// User-created collections
    var userCollections: [Collection] { get set }

    /// Check if an item is marked as favorite
    func isFavorite(_ item: Item) -> Bool

    /// Toggle favorite status of an item
    func toggleFavorite(_ item: Item)

    /// Add an item to favorites
    func addFavorite(_ item: Item)

    /// Remove an item from favorites
    func removeFavorite(_ item: Item)
}
