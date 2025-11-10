import Foundation

public enum NetworkBaseURL: String, Sendable {
    case `default`
    case purchases
    case purchasesSandbox
    // Add feature-specific cases as needed, e.g. items, auth, profile, etc.
}

public struct NetworkConfiguration: Sendable {
    public let baseURLs: [NetworkBaseURL: URL]

    public init(baseURLs: [NetworkBaseURL: URL]) {
        self.baseURLs = baseURLs
    }

    public func url(for base: NetworkBaseURL) -> URL? {
        baseURLs[base] ?? baseURLs[.default]
    }
}

public protocol NetworkClientProtocol: Sendable {
    func get<T: Decodable>(
        _ path: String,
        base: NetworkBaseURL,
        query: [String: String]?
    ) async throws -> T

    func post<T: Decodable, Body: Encodable>(
        _ path: String,
        base: NetworkBaseURL,
        body: Body?,
        query: [String: String]?
    ) async throws -> T

    func post(
        _ path: String,
        base: NetworkBaseURL,
        body: Data?,
        headers: [String: String]?
    ) async throws
}
