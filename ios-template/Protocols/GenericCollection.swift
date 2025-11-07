//
//  GenericCollection.swift
//  ios-template
//
//  Generic protocol for collections of items.
//

import SwiftUI

/// Protocol that defines a collection of generic items
///
/// Use this protocol to create collections or groups of items in your application.
/// Collections can be used for favorites, user-created lists, or any grouping of items.
///
/// Example conformance:
/// ```swift
/// @Observable
/// class ItemCollection: GenericCollection {
///     typealias item = Item
///     var id = UUID()
///     var items: [Item]
///     var heading: String?
///
///     init(items: [Item] = [], heading: String? = nil) {
///         self.items = items
///         self.heading = heading
///     }
/// }
/// ```
public protocol GenericCollection: Identifiable, Codable, Hashable {
    associatedtype Item: GenericItem

    /// Unique identifier for the collection
    var id: UUID { get }

    /// Items contained in this collection
    var items: [Item] { get set }

    /// Optional heading or name for the collection
    var heading: String? { get set }
}
