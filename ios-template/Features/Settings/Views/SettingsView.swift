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
    @Injected private var viewModel: SettingsViewModel
    @Environment(PurchaseManager.self) private var purchaseManager

    public init(viewModel: SettingsViewModel? = nil) {
        if let viewModel {
            _viewModel = Injected(wrappedValue: viewModel)
        } else {
            _viewModel = Injected()
        }
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
                HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                    AnimatedSymbol.favorite("checkmark.seal.fill", isFavorite: true)
                        .foregroundColor(DesignSystem.Colors.success)
                        .font(.system(size: 20))  // iOS 26: Larger icon
                    Text("Premium Unlocked")
                        .font(DesignSystem.Typography.bodyMedium)
                }
                .padding(.vertical, DesignSystem.Spacing.xxs)  // iOS 26: Better vertical spacing
            } else {
                Button {
                    viewModel.showPaywall()
                } label: {
                    HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                        AnimatedSymbol("star.fill", effect: .wiggle, trigger: true)
                            .foregroundColor(DesignSystem.Colors.warning)
                            .font(.system(size: 20))  // iOS 26: Larger icon
                        Text("Unlock Premium")
                            .font(DesignSystem.Typography.bodyMedium)
                        Spacer()
                        AnimatedSymbol("chevron.right")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    .padding(.vertical, DesignSystem.Spacing.xxs)  // iOS 26: Better touch target
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
            HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                Text("Version")
                    .font(DesignSystem.Typography.bodyMedium)
                Spacer()
                Text(appVersion)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .padding(.vertical, DesignSystem.Spacing.xxs)  // iOS 26: Better vertical spacing

            Link(destination: URL(string: "https://natecard.dev")!) {
                HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                    Text("Website")
                        .font(DesignSystem.Typography.bodyMedium)
                    Spacer()
                    AnimatedSymbol("arrow.up.right", effect: .scale, trigger: true)
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.xxs)  // iOS 26: Better touch target
            }

            Link(destination: URL(string: "https://github.com/natecard/ios-template")!) {
                HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                    Text("GitHub")
                        .font(DesignSystem.Typography.bodyMedium)
                    Spacer()
                    AnimatedSymbol("arrow.up.right", effect: .scale, trigger: true)
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.xxs)  // iOS 26: Better touch target
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
                    HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
                        AnimatedSymbol.loading("arrow.trianglehead.2.clockwise.rotate.90", isLoading: true)
                            .font(.system(size: 16))
                        Text("Deleting...")
                    }
                    .padding(.vertical, DesignSystem.Spacing.xxs)  // iOS 26: Better vertical spacing
                } else {
                    Text("Delete All Data")
                        .padding(.vertical, DesignSystem.Spacing.xxs)  // iOS 26: Better vertical spacing
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
            purchaseManager: PreviewDependencies.purchaseManager,
            dataManager: ItemDataManager(
                persistenceService: try! JSONPersistenceService()
            )
        )
    )
    .environment(PreviewDependencies.purchaseManager)
}
