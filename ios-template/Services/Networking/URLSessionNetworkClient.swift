import Foundation

public final class URLSessionNetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let configuration: NetworkConfiguration

    public init(session: URLSession = .shared, configuration: NetworkConfiguration) {
        self.session = session
        self.configuration = configuration
    }

    private func makeURL(base: NetworkBaseURL, path: String) throws -> URL {
        guard let baseURL = configuration.url(for: base) else {
            throw URLError(.badURL)
        }
        if path.isEmpty { return baseURL }
        return baseURL.appendingPathComponent(path)
    }

    public func get<T: Decodable>(
        _ path: String,
        base: NetworkBaseURL,
        query: [String: String]? = nil
    ) async throws -> T {
        let url = try makeURL(base: base, path: path)
        return try await requestDecodable(url: url, method: "GET", body: nil, headers: ["Accept": "application/json"], query: query)
    }

    public func post<T: Decodable, Body: Encodable>(
        _ path: String,
        base: NetworkBaseURL,
        body: Body?,
        query: [String: String]? = nil
    ) async throws -> T {
        let url = try makeURL(base: base, path: path)
        let data = try body.map { try JSONEncoder().encode($0) }
        let headers = ["Content-Type": "application/json", "Accept": "application/json"]
        return try await requestDecodable(url: url, method: "POST", body: data, headers: headers, query: query)
    }

    public func post(
        _ path: String,
        base: NetworkBaseURL,
        body: Data?,
        headers: [String: String]? = nil
    ) async throws {
        let url = try makeURL(base: base, path: path)
        _ = try await request(url: url, method: "POST", body: body, headers: headers, query: nil)
    }

    // MARK: - Internal helpers

    private func requestDecodable<T: Decodable>(
        url: URL,
        method: String,
        body: Data?,
        headers: [String: String]?,
        query: [String: String]?
    ) async throws -> T {
        let data = try await request(url: url, method: method, body: body, headers: headers, query: query)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    private func request(
        url: URL,
        method: String,
        body: Data?,
        headers: [String: String]?,
        query: [String: String]?
    ) async throws -> Data {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let query = query, !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.serverError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}
