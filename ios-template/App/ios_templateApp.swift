//
//  ios_templateApp.swift
//  ios-template
//
//  Main entry point for the iOS app.
//

import SwiftUI

@main
struct Ios_templateApp: App {
    @State private var environment: AppEnvironment

    init() {
        do {
            _environment = State(initialValue: try AppEnvironment())
        } catch {
            fatalError("Failed to initialize AppEnvironment: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environment(environment)
                .environment(environment.purchaseManager)
                .environment(environment.dataManager)
                .onAppear {
                    environment.start()
                }
        }
    }
}

/// Main tab view of the app
struct AppTabView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        TabView {
            // Items List Tab
            ItemsListView(
                viewModel: ItemsListViewModel(
                    repository: environment.repository,
                    dataManager: environment.dataManager
                )
            )
            .tabItem {
                Label("Items", systemImage: "house.fill")
            }

            // Search Tab
            SearchView(
                viewModel: SearchViewModel(
                    repository: environment.repository,
                    dataManager: environment.dataManager
                )
            )
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            // Settings Tab
            SettingsView(
                viewModel: SettingsViewModel(
                    purchaseManager: environment.purchaseManager,
                    dataManager: environment.dataManager,
                    fileStorage: environment.fileStorage
                )
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}
