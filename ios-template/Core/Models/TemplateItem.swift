//  
// TemplateItem.swift
//  ios-template
//
//  Default item model used by the template.
// 

import Foundation

public struct TemplateItem: GenericItem {
    public let id: String
    public let title: String
    public let summary: String
    public let creator: String
    public let createdDate: Date
    public let categories: [String]
    public let primaryCategory: String
    public let hasAttachment: Bool
    public let attachmentURL: URL?

    public init(
        id: String,
        title: String,
        summary: String,
        creator: String,
        createdDate: Date,
        categories: [String] = [],
        primaryCategory: String = "General",
        hasAttachment: Bool = false,
        attachmentURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.creator = creator
        self.createdDate = createdDate
        self.categories = categories
        self.primaryCategory = primaryCategory
        self.hasAttachment = hasAttachment
        self.attachmentURL = attachmentURL
    }
}
