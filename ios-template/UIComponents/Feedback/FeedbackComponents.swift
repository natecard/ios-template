//
//  FeedbackComponents.swift
//  ios-template
//
// Components for user feedback such as loading indicators, skeleton views, progress bars, and toast notifications.
//

import SwiftUI

// MARK: - Loading States
struct LoadingView: View {
    let message: String?
    let style: LoadingStyle

    enum LoadingStyle {
        case small, medium, large

        var size: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 32
            case .large: return 48
            }
        }

        var strokeWidth: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 3
            case .large: return 4
            }
        }
    }

    init(message: String? = nil, style: LoadingStyle = .medium) {
        self.message = message
        self.style = style
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {  // iOS 26: Increased spacing
            AnimatedSymbol.loading("arrow.trianglehead.2.clockwise.rotate.90", isLoading: true)
            .font(.system(size: style.size))
            .foregroundColor(DesignSystem.Colors.primary)
            if let message = message {
                Text(message)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DesignSystem.Spacing.xl)  // iOS 26: Increased padding
    }
}

// MARK: - Skeleton Loading
struct SkeletonView: View {
    @Environment(\.motionStyle) private var motionStyle

    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    init(width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat = DesignSystem.BorderRadius.sm) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(baseFill)
            .frame(width: width, height: height)
            .overlay(shimmerOverlay.cornerRadius(cornerRadius))
    }

    private var baseFill: AnyShapeStyle {

        return AnyShapeStyle(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.secondaryBackground,
                    DesignSystem.Colors.tertiaryBackground,
                    DesignSystem.Colors.secondaryBackground,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var shimmerOverlay: some View {
        Group {
            if motionStyle.motionEnabled {
                SkeletonShimmerOverlay(
                    duration: motionStyle.shimmerDuration,
                    highlightOpacity: 0.2 + motionStyle.amplitude(0.12),
                    highlightWidthMultiplier: 0.45 + motionStyle.amplitude(0.25)
                )
            }
        }
    }
}

private struct SkeletonShimmerOverlay: View {
    let duration: Double
    let highlightOpacity: Double
    let highlightWidthMultiplier: CGFloat

    init(duration: Double, highlightOpacity: Double, highlightWidthMultiplier: CGFloat) {
        self.duration = max(0.3, duration)
        self.highlightOpacity = highlightOpacity
        self.highlightWidthMultiplier = max(0.3, highlightWidthMultiplier)
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            TimelineView(.animation(minimumInterval: duration / 2)) { context in
                let progress = progress(for: context.date)
                shimmer(size: size, progress: progress)
            }
        }
        .allowsHitTesting(false)
    }

    private func shimmer(size: CGSize, progress: Double) -> some View {
        let width = max(size.width, 1)
        let shimmerWidth = width * highlightWidthMultiplier
        let travel = width + shimmerWidth
        let offset = travel * progress - shimmerWidth

        return LinearGradient(
            colors: [
                DesignSystem.Colors.clear,
                DesignSystem.Colors.white.opacity(highlightOpacity),
                DesignSystem.Colors.clear,
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: shimmerWidth, height: max(size.height, 1))
        .offset(x: offset)
    }

    private func progress(for date: Date) -> Double {
        let remainder = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration)
        return remainder / duration
    }
}

// MARK: - Item Skeleton
struct ItemSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Title skeleton
            SkeletonView(width: nil, height: 20, cornerRadius: DesignSystem.BorderRadius.xs)

            // Subtitle skeleton
            SkeletonView(width: 120, height: 16, cornerRadius: DesignSystem.BorderRadius.xs)

            // Description skeleton lines
            VStack(spacing: DesignSystem.Spacing.xs) {
                SkeletonView(width: nil, height: 14, cornerRadius: DesignSystem.BorderRadius.xs)
                SkeletonView(width: nil, height: 14, cornerRadius: DesignSystem.BorderRadius.xs)
                SkeletonView(width: 200, height: 14, cornerRadius: DesignSystem.BorderRadius.xs)
            }

            // Tags skeleton
            HStack(spacing: DesignSystem.Spacing.sm) {
                SkeletonView(width: 80, height: 24, cornerRadius: DesignSystem.BorderRadius.sm)
                SkeletonView(width: 60, height: 24, cornerRadius: DesignSystem.BorderRadius.sm)
                SkeletonView(width: 100, height: 24, cornerRadius: DesignSystem.BorderRadius.sm)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .designCornerRadius(DesignSystem.BorderRadius.md)
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let progress: Double
    let title: String?
    let showPercentage: Bool
    let style: ProgressBarStyle

    enum ProgressBarStyle {
        case primary, success, warning, error

        var color: Color {
            switch self {
            case .primary: return DesignSystem.Colors.primary
            case .success: return DesignSystem.Colors.success
            case .warning: return DesignSystem.Colors.warning
            case .error: return DesignSystem.Colors.error
            }
        }
    }

    init(
        progress: Double,
        title: String? = nil,
        showPercentage: Bool = false,
        style: ProgressBarStyle = .primary
    ) {
        self.progress = max(0, min(1, progress))
        self.title = title
        self.showPercentage = showPercentage
        self.style = style
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            if let title = title {
                HStack {
                    Text(title)
                        .font(DesignSystem.Typography.labelMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Spacer()

                    if showPercentage {
                        Text("\(Int(progress * 100))%")
                            .font(DesignSystem.Typography.labelSmall)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(DesignSystem.Colors.secondaryBackground)
                        .frame(height: 8)
                        .designCornerRadius(DesignSystem.BorderRadius.full)

                    Rectangle()
                        .fill(style.color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .designCornerRadius(DesignSystem.BorderRadius.full)
                        .animation(DesignSystem.Animation.normal, value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Toast Notification
struct ToastNotification: View {
    let title: String
    let message: String?
    let type: ToastType
    let onDismiss: () -> Void

    enum ToastType {
        case success, warning, error, info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return DesignSystem.Colors.success
            case .warning: return DesignSystem.Colors.warning
            case .error: return DesignSystem.Colors.error
            case .info: return DesignSystem.Colors.info
            }
        }
    }

    init(
        title: String,
        message: String? = nil,
        type: ToastType = .info,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.type = type
        self.onDismiss = onDismiss
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {  // iOS 26: Increased spacing
            AnimatedSymbol(type.icon, effect: .bounce, trigger: true)
                .foregroundColor(type.color)
                .font(.system(size: 22, weight: .medium))  // iOS 26: Larger icon

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.titleSmall)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                if let message = message {
                    Text(message)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button(action: onDismiss) {
                AnimatedSymbol("xmark", effect: .scale, trigger: true)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .font(.system(size: 16, weight: .medium))
            }
            .buttonStyle(.plain)
        }
        .padding(DesignSystem.Spacing.lg)  // iOS 26: Increased padding
        .liquidGlass(.floating)  // iOS 26: Liquid Glass toast
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.lg))  // iOS 26: Larger corner radius
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.lg)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Pull to Refresh
struct PullToRefreshView: View {
    let isRefreshing: Bool
    let onRefresh: () -> Void

    var body: some View {
        if isRefreshing {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))

                Text("Refreshing...")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Preview
#if DEBUG
    struct FeedbackComponents_Previews: PreviewProvider {
        @State static var progress = 0.7
        @State static var showToast = false

        static var previews: some View {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    LoadingView(message: "Loading items...", style: .large)

                    ItemSkeleton()

                    ProgressBar(
                        progress: progress,
                        title: "Download Progress",
                        showPercentage: true,
                        style: .success
                    )

                    Button("Show Toast") {
                        showToast = true
                    }
                    .sheet(isPresented: $showToast) {
                        ToastNotification(
                            title: "Success!",
                            message: "Item has been added to your collection.",
                            type: .success
                        ) {
                            showToast = false
                        }
                        .padding()
                    }

                    PullToRefreshView(isRefreshing: true) {}
                }
                .padding()
            }
            .background(DesignSystem.Colors.background)
        }
    }
#endif
