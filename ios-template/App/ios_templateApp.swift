//
//  ios_templateApp.swift
//  ios-template
//
//  Main entry point for the iOS app.
//

import SwiftUI

@main
struct Ios_templateApp: App {
    @State private var container: AppContainer?
    @State private var purchaseManager: PurchaseManager?
    @State private var bootstrapError: Error?

    var body: some Scene {
        WindowGroup {
            Group {
                if let container, let purchaseManager {
                    AppTabView()
                        .environment(\.appContainer, container)
                        .environment(purchaseManager)
                } else if let error = bootstrapError {
                    VStack(spacing: 16) {
                        Text("Unable to Start App")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else {
                    ProgressView("Loading…")
                }
            }
            .task {
                await performBootstrap()
            }
        }
    }

    @MainActor
    private func setUpPurchaseManager(with container: AppContainer) {
        guard purchaseManager == nil,
            let manager: PurchaseManager = container.resolve(PurchaseManager.self)
        else {
            return
        }

        PurchaseManagerBridge.shared.purchaseManagerRef = manager
        manager.start()
        purchaseManager = manager
    }

    private func performBootstrap() async {
        guard container == nil else { return }

        do {
            let container = try await BootstrapActor.shared.bootstrap()
            await MainActor.run {
                self.container = container
                setUpPurchaseManager(with: container)
            }
        } catch {
            await MainActor.run {
                bootstrapError = error
            }
        }
    }
}

/// Main tab view of the app
struct AppTabView: View {
    var body: some View {
        TabView {
            ItemsListView()
                .tabItem {
                    Label("Items", systemImage: "house.fill")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
