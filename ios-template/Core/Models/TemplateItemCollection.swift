//
//   TemplateItemCollection.swift
//  ios-template
//
//  Default collection model used by the template.
//

import SwiftUI

public struct TemplateItemCollection: GenericCollection, Sendable {
    public var id: UUID
    public var items: [TemplateItem]
    public var heading: String?

    public init(id: UUID = UUID(), items: [TemplateItem], heading: String? = nil) {
        self.id = id
        self.items = items
        self.heading = heading
    }

    // MARK: - Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, items, heading
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.items = try container.decode([TemplateItem].self, forKey: .items)
        self.heading = try container.decodeIfPresent(String.self, forKey: .heading)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(heading, forKey: .heading)
    }

    // MARK: - Hashable conformance
    public static func == (lhs: TemplateItemCollection, rhs: TemplateItemCollection) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
