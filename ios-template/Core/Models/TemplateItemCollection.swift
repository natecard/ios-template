//  TemplateItemCollection.swift
//  ios-template
//
//  Default collection model used by the template.

import SwiftUI

@Observable
public class TemplateItemCollection: GenericCollection {
    public var id = UUID()
    public var items: [TemplateItem]
    public var heading: String?

    public init(items: [TemplateItem], heading: String? = nil) {
        self.items = items
        self.heading = heading
    }

    // MARK: - Hashable conformance
    public static func == (lhs: TemplateItemCollection, rhs: TemplateItemCollection) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
