//
//  ios_templateApp.swift
//  ios-template
//
//  Main entry point for the iOS app.
//

/// The main application structure conforming to the `App` protocol.
///
/// `Ios_templateApp` serves as the entry point for the iOS application and manages the initialization
/// of the dependency injection container. It supports two modes of operation:
///
/// ## Dependency Injection Modes
///
/// ### Zero-Dependency Mode (Default)
/// Uses `ZeroDependencyAppContainer` with `URLSession` and manual dependency wiring.
/// This is the active configuration and requires no external dependencies.
///
/// ### Swinject Mode (Optional)
/// Uses `AppContainer` with Swinject and Alamofire for advanced dependency injection.
/// To enable this mode:
/// 1. Add Swinject and Alamofire to your project target
/// 2. Uncomment the `container` state property and related bootstrap methods
/// 3. Comment out the zero-dependency bootstrap code
///
/// ## Bootstrap Process
///
/// The app bootstraps asynchronously on launch using the `.task` modifier:
/// - Initializes the selected DI container
/// - Sets up the `PurchaseManager` via `PurchaseManagerBridge`
/// - Injects dependencies into the SwiftUI view hierarchy using environment values
///
/// ## Error Handling
///
/// If bootstrap fails, the app displays an error screen with the localized error description
/// instead of the main interface.
///
/// ## State Properties
///
/// - `zeroContainer`: The zero-dependency container (active by default)
/// - `purchaseManager`: Manages in-app purchases across both DI modes
/// - `bootstrapError`: Captures any errors during the bootstrap process
/// - `container`: (Commented out) The Swinject-based container for advanced DI
///
/// - Note: Only one DI mode should be active at a time for code clarity.
/// - SeeAlso: `ZeroDependencyAppContainer`, `AppContainer`, `PurchaseManager`

import SwiftUI

@main
struct Ios_templateApp: App {
    // Default: Zero-dependency (URLSession + manual wiring).
    @State private var zeroContainer: ZeroDependencyAppContainer?
    @State private var purchaseManager: PurchaseManager?
    @State private var bootstrapError: Error?

    // Optional: Swinject + Alamofire via `AppContainer` / `BootstrapActor`.
    // To enable advanced DI:
    // 1. Add Swinject + Alamofire to your target.
    // 2. Uncomment the `AppContainer` state and Swinject bootstrap below.
    // 3. Comment out the zero-dependency bootstrap.
    //
    // @State private var container: AppContainer?

    var body: some Scene {
        WindowGroup {
            Group {
                if let zeroContainer, let purchaseManager {
                    AppTabView()
                        // In zero-dependency mode, inject as needed (example uses environment key if you define one).
                        // .environment(\.appContainer, zeroContainer)
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
                await performZeroDependencyBootstrap()
                // For Swinject/Alamofire mode instead, call:
                // await performBootstrap()
            }
        }
    }

    // MARK: - Swinject/Alamofire bootstrap (optional)
    //
    // To enable this path, ensure Swinject & Alamofire are added and wired.
    // Then uncomment this section and the `container` state above.
    //
    // @MainActor
    // private func setUpPurchaseManager(with container: AppContainer) {
    //     guard purchaseManager == nil,
    //         let manager: PurchaseManager = container.resolve(PurchaseManager.self)
    //     else {
    //         return
    //     }
    //
    //     PurchaseManagerBridge.shared.purchaseManagerRef = manager
    //     manager.start()
    //     purchaseManager = manager
    // }
    //
    // private func performBootstrap() async {
    //     guard container == nil else { return }
    //
    //     do {
    //         let container = try await BootstrapActor.shared.bootstrap()
    //         await MainActor.run {
    //             self.container = container
    //             setUpPurchaseManager(with: container)
    //         }
    //     } catch {
    //         await MainActor.run {
    //             bootstrapError = error
    //         }
    //     }
    // }

    // MARK: - Zero-dependency bootstrap (default)
    private func performZeroDependencyBootstrap() async {
        guard zeroContainer == nil else { return }

        do {
            let container = try await ZeroDependencyBootstrapActor.shared.bootstrap()
            await MainActor.run {
                self.zeroContainer = container
                // PurchaseManager is already built inside ZeroDependencyAppContainer.
                PurchaseManagerBridge.shared.purchaseManagerRef = container.purchaseManager
                container.purchaseManager.start()
                self.purchaseManager = container.purchaseManager
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
