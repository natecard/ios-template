//
//  FileExtension.swift
//  ios-template
//
//  Enum defining supported file extensions for storage operations.
//

import Foundation

/// Supported file extensions for file storage operations
///
/// Add cases to this enum to support additional file types in your application.
///
/// Example usage:
/// ```swift
/// let url = try await storage.store(
///     data: pdfData,
///     for: item,
///     scope: .local,
///     fileExtension: .pdf
/// )
/// ```
public enum FileExtension: String, Codable, CaseIterable, Sendable {
    case pdf
    case html
    case epub
    case txt
    case json
    case xml
    case png
    case jpg
    case jpeg
    case gif
    case mp4
    case mp3
    case zip

    /// File extension string with leading dot (e.g., ".pdf")
    public var withDot: String {
        "." + rawValue
    }

    /// MIME type for the file extension
    public var mimeType: String {
        switch self {
        case .pdf:
            return "application/pdf"
        case .html:
            return "text/html"
        case .epub:
            return "application/epub+zip"
        case .txt:
            return "text/plain"
        case .json:
            return "application/json"
        case .xml:
            return "application/xml"
        case .png:
            return "image/png"
        case .jpg, .jpeg:
            return "image/jpeg"
        case .gif:
            return "image/gif"
        case .mp4:
            return "video/mp4"
        case .mp3:
            return "audio/mpeg"
        case .zip:
            return "application/zip"
        }
    }

    /// Human-readable description
    public var description: String {
        switch self {
        case .pdf:
            return "PDF Document"
        case .html:
            return "HTML Document"
        case .epub:
            return "EPUB Book"
        case .txt:
            return "Text File"
        case .json:
            return "JSON Data"
        case .xml:
            return "XML Document"
        case .png:
            return "PNG Image"
        case .jpg, .jpeg:
            return "JPEG Image"
        case .gif:
            return "GIF Image"
        case .mp4:
            return "MP4 Video"
        case .mp3:
            return "MP3 Audio"
        case .zip:
            return "ZIP Archive"
        }
    }
}
