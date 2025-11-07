//
//  SettingsComponents.swift
//  ios-template
//
//  Standardized UI components for settings screens.
//

import SwiftUI

// MARK: - Settings Row

/// A standardized row component for displaying key-value pairs in settings
struct SettingsRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            Spacer()
            Text(value)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - Settings Link Row

/// A standardized row component for displaying a label with an action button
struct SettingsLinkRow: View {
    let label: String
    let buttonText: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(label)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            GhostButton(
                buttonText,
                size: .medium,
                isFullWidth: true,
                action: action
            )
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - Settings Section Divider

/// A standardized divider component for separating items within settings sections
struct SettingsSectionDivider: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .overlay(DesignSystem.Colors.borderLight)
    }
}

// MARK: - Previews

#if DEBUG
    struct SettingsComponents_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                // Light Mode Preview
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Text("Settings Components - Light Mode")
                        .font(DesignSystem.Typography.titleLarge)
                        .padding(.bottom, DesignSystem.Spacing.sm)

                    VStack(spacing: DesignSystem.Spacing.md) {
                        SettingsRow(label: "Version", value: "1.0.0")

                        SettingsSectionDivider()

                        SettingsRow(label: "Build", value: "123")

                        SettingsSectionDivider()

                        SettingsLinkRow(
                            label: "Developed by",
                            buttonText: "Nate Card"
                        ) {
                            print("Link tapped")
                        }
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.surface)
                    .designCornerRadius(DesignSystem.BorderRadius.md)
                }
                .padding(DesignSystem.Spacing.lg)
                .background(DesignSystem.Colors.background)
                .preferredColorScheme(.light)

                // Dark Mode Preview
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Text("Settings Components - Dark Mode")
                        .font(DesignSystem.Typography.titleLarge)
                        .padding(.bottom, DesignSystem.Spacing.sm)

                    VStack(spacing: DesignSystem.Spacing.md) {
                        SettingsRow(label: "Version", value: "1.0.0")

                        SettingsSectionDivider()

                        SettingsRow(label: "Build", value: "123")

                        SettingsSectionDivider()

                        SettingsLinkRow(
                            label: "Developed by",
                            buttonText: "Nate Card"
                        ) {
                            print("Link tapped")
                        }
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.surface)
                    .designCornerRadius(DesignSystem.BorderRadius.md)
                }
                .padding(DesignSystem.Spacing.lg)
                .background(DesignSystem.Colors.background)
                .preferredColorScheme(.dark)
            }
        }
    }
#endif
