//
//  SettingsView.swift
//  ios-template
//
//  Settings screen view.
//

import SwiftUI

/// Settings screen view
///
/// Displays app settings, purchases, and account management.
public struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @Environment(PurchaseManager.self) private var purchaseManager

    public init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            List {
                // Premium Section
                premiumSection

                // About Section
                aboutSection

                // Danger Zone
                dangerZoneSection
            }
            .navigationTitle("Settings")
            .alert("Delete All Data?", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteAllData()
                    }
                }
            } message: {
                Text(
                    "This will permanently delete all your favorites, collections, and downloaded files. This action cannot be undone."
                )
            }
            .sheet(
                isPresented: Binding(
                    get: { purchaseManager.isPaywallPresented },
                    set: { purchaseManager.isPaywallPresented = $0 }
                )
            ) {
                FullUnlockPaywallView()
            }
        }
    }

    // MARK: - Sections

    private var premiumSection: some View {
        Section {
            if viewModel.isPremium {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(DesignSystem.Colors.success)
                    Text("Premium Unlocked")
                        .font(DesignSystem.Typography.bodyMedium)
                }
            } else {
                Button {
                    viewModel.showPaywall()
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(DesignSystem.Colors.warning)
                        Text("Unlock Premium")
                            .font(DesignSystem.Typography.bodyMedium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
            }

            Button {
                Task {
                    await viewModel.restorePurchases()
                }
            } label: {
                Text("Restore Purchases")
                    .font(DesignSystem.Typography.bodyMedium)
            }
        } header: {
            Text("Premium")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                    .font(DesignSystem.Typography.bodyMedium)
                Spacer()
                Text(appVersion)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            Link(destination: URL(string: "https://natecard.dev")!) {
                HStack {
                    Text("Website")
                        .font(DesignSystem.Typography.bodyMedium)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }

            Link(destination: URL(string: "https://github.com/natecard/ios-template")!) {
                HStack {
                    Text("GitHub")
                        .font(DesignSystem.Typography.bodyMedium)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
        } header: {
            Text("About")
        }
    }

    private var dangerZoneSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showingDeleteConfirmation = true
            } label: {
                if viewModel.isDeleting {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Deleting...")
                    }
                } else {
                    Text("Delete All Data")
                }
            }
            .disabled(viewModel.isDeleting)

            if let error = viewModel.deleteError {
                Text(error)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundColor(DesignSystem.Colors.error)
            }
        } header: {
            Text("Danger Zone")
        } footer: {
            Text("This will permanently delete all your favorites, collections, and downloaded files.")
                .font(DesignSystem.Typography.bodySmall)
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Previews

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(
            purchaseManager: PurchaseManager(),
            dataManager: ItemDataManager(
                persistenceService: try! JSONPersistenceService()
            )
        )
    )
    .environment(PurchaseManager())
}
