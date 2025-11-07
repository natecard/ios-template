//
//  FullUnlockPaywallView.swift
//  ios-template
//
//
//

import StoreKit
import SwiftUI

struct FullUnlockPaywallView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        content
            .padding(DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.surface)
            .designCornerRadius(DesignSystem.BorderRadius.lg)
            .designShadow(DesignSystem.Shadows.large)
            .safeAreaInset(edge: .bottom) { bottomButtons }
            .task { await purchaseManager.refreshProducts() }
            #if os(iOS)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            #endif
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                header
                perks
                pricing
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Image(systemName: "lock.open")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.primary)
                .padding(8)
                .background(DesignSystem.Colors.primary.opacity(0.1))
                .designCornerRadius(DesignSystem.BorderRadius.sm)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Unlock Full App")
                    .font(DesignSystem.Typography.headlineSmall)
                Text("Get iCloud PDF sync and future premium features.")
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }

            Spacer()

            #if os(iOS)
                ToolbarIconButton(icon: "xmark", size: .small) {
                    purchaseManager.dismissPaywall()
                }
                .accessibilityLabel("Close")
            #endif
        }
    }

    private var perks: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("What you get")
                .font(DesignSystem.Typography.titleSmall)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                benefitRow(
                    icon: "icloud",
                    title: "iCloud",
                    subtitle: "Sync your data across all your devices"
                )
                benefitRow(
                    icon: "sparkles",
                    title: "Premium Enhancements",
                    subtitle: "Access future pro features as they ship"
                )
                benefitRow(
                    icon: "heart",
                    title: "Support Development",
                    subtitle: "Help improve the app with your purchase"
                )
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.sm)
        }
    }

    private func benefitRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.primary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(DesignSystem.Typography.bodyMedium)
                Text(subtitle)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
        }
    }

    private var pricing: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("One-time purchase")
                .font(DesignSystem.Typography.labelMedium)
                .foregroundStyle(DesignSystem.Colors.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.sm) {
                Text(purchaseManager.fullUnlockProduct?.displayPrice ?? "")
                    .font(DesignSystem.Typography.headlineSmall)
                if let product = purchaseManager.fullUnlockProduct {
                    Text(product.displayName)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
        }
    }

    private var bottomButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            PrimaryButton(
                purchaseManager.isProcessingPurchase ? "Processing…" : "Unlock Full App",
                icon: purchaseManager.isProcessingPurchase ? nil : "lock.open.fill",
                size: .large,
                isLoading: purchaseManager.isProcessingPurchase,
                isDisabled: purchaseManager.isProcessingPurchase
                    || purchaseManager.fullUnlockProduct == nil,
                isFullWidth: true
            ) {
                Task { @MainActor in _ = await purchaseManager.purchaseFullUnlock() }
            }

            SecondaryButton(
                purchaseManager.isProcessingRestore ? "Restoring…" : "Restore Purchase",
                icon: "arrow.clockwise",
                size: .medium,
                isDisabled: purchaseManager.isProcessingRestore || purchaseManager.isProcessingPurchase,
                isFullWidth: true
            ) {
                Task { @MainActor in
                    await purchaseManager.restorePurchases()
                    if purchaseManager.isFullAppUnlocked {
                        purchaseManager.dismissPaywall()
                    }
                }
            }

            Button(action: { purchaseManager.dismissPaywall() }) {
                Text("Not now")
                    .font(DesignSystem.Typography.labelMedium)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.surface)
    }
}

#if DEBUG
    #Preview {
        FullUnlockPaywallView()
            .environment(PurchaseManager())
    }
#endif
