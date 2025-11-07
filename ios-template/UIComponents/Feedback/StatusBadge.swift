//
//  StatusBadge.swift
//  ios-template
//
// Status badge view for displaying status indicators with icons and optional loading state.
//

import SwiftUI

struct StatusBadge: View {
    let text: String
    let icon: String
    var isLoading: Bool = false
    var type: BadgeType = .neutral

    enum BadgeType {
        case primary
        case success
        case warning
        case error
        case info
        case neutral

        var backgroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.primary.opacity(0.1)
            case .success: return DesignSystem.Colors.success.opacity(0.1)
            case .warning: return DesignSystem.Colors.warning.opacity(0.1)
            case .error: return DesignSystem.Colors.error.opacity(0.1)
            case .info: return DesignSystem.Colors.info.opacity(0.1)
            case .neutral: return DesignSystem.Colors.surfaceTertiary
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.primary
            case .success: return DesignSystem.Colors.success
            case .warning: return DesignSystem.Colors.warning
            case .error: return DesignSystem.Colors.error
            case .info: return DesignSystem.Colors.info
            case .neutral: return DesignSystem.Colors.textSecondary
            }
        }
    }

    init(_ text: String, icon: String, isLoading: Bool = false, type: BadgeType = .neutral) {
        self.text = text
        self.icon = icon
        self.isLoading = isLoading
        self.type = type
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.7)
                    .foregroundColor(type.foregroundColor)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(type.foregroundColor)
            }

            Text(text)
                .font(DesignSystem.Typography.labelSmall)
                .foregroundColor(type.foregroundColor)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(type.backgroundColor)
        .designCornerRadius(DesignSystem.BorderRadius.xs)
    }
}

#if DEBUG
    struct StatusBadge_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: 8) {
                StatusBadge("Primary", icon: "checkmark.circle", type: .primary)
                StatusBadge("Success", icon: "checkmark.circle.fill", type: .success)
                StatusBadge("Warning", icon: "exclamationmark.triangle", type: .warning)
                StatusBadge("Error", icon: "xmark.circle", type: .error)
                StatusBadge("Info", icon: "info.circle", type: .info)
                StatusBadge("Neutral", icon: "circle", type: .neutral)
                StatusBadge("Loading", icon: "arrow.clockwise", isLoading: true, type: .info)
            }
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }
#endif
