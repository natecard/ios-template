import Foundation
import Alamofire

public final class AlamofireNetworkClient: NetworkClientProtocol {
    private let session: Session
    private let configuration: NetworkConfiguration
    
    public init(session: Session = .default, configuration: NetworkConfiguration) {
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
        return try await requestDecodable(url: url, method: .get, body: nil, parameters: query)
    }
    
    public func post<T: Decodable, Body: Encodable>(
        _ path: String,
        base: NetworkBaseURL,
        body: Body?,
        query: [String: String]? = nil
    ) async throws -> T {
        let url = try makeURL(base: base, path: path)
        let data = try body.map { try JSONEncoder().encode($0) }
        return try await requestDecodable(url: url, method: .post, body: data, parameters: query)
    }
    
    public func post(
        _ path: String,
        base: NetworkBaseURL,
        body: Data?,
        headers: [String: String]? = nil
    ) async throws {
        let url = try makeURL(base: base, path: path)
        _ = try await request(url: url, method: .post, body: body, headers: headers, parameters: nil)
    }
    
        // MARK: - Internal helpers
    
    private func requestDecodable<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        body: Data?,
        parameters: [String: String]?
    ) async throws -> T {
        let data = try await request(url: url, method: method, body: body, headers: ["Content-Type": "application/json"], parameters: parameters)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    private func request(
        url: URL,
        method: HTTPMethod,
        body: Data?,
        headers: [String: String]?,
        parameters: [String: String]?
    ) async throws -> Data {
        var urlRequest = try URLRequest(url: url, method: method)
        
        if let headers = headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let parameters = parameters {
            urlRequest = try URLEncoding(destination: .queryString).encode(urlRequest, with: parameters)
        }
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(urlRequest)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .success:
                        continuation.resume(returning: Data())
                    case .failure(let error):
                        continuation.resume(throwing: Self.mapError(error, response.response))
                    }
                }
        }
    }

    // MARK: - Error Mapping

    private static func mapError(_ error: AFError, _ response: HTTPURLResponse?) -> Error {
        if let urlError = error.underlyingError as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost:
                return AppError.networkUnavailable
            default:
                break
            }
        }

        if let statusCode = response?.statusCode {
            if !(200...299).contains(statusCode) {
                return AppError.serverError(statusCode: statusCode)
            }
        }

        if case .responseSerializationFailed(let reason) = error,
           case .decodingFailed(let decodingError) = reason {
            return AppError.decodingError(decodingError.localizedDescription)
        }

        if case .invalidURL(let urlConvertible) = error {
            return AppError.invalidURL("\(urlConvertible)")
        }

        return error
    }
}
