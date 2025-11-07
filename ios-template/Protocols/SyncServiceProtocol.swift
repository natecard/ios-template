import Foundation

protocol SyncServiceProtocol: Sendable {
    func isCloudAvailable() async -> Bool
    func cloudRootURL() async -> URL?

    func enableCloudSync() async throws
    func migrateLocalPDFsToCloudIfNeeded() async throws

    func localPDFURL(for item: any GenericItem) async -> URL?
    func cloudPDFURL(for item: any GenericItem) async -> URL?
    func preferredPDFURL(for item: any GenericItem) async -> URL?
}
