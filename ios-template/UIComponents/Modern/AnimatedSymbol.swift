//
//  AnimatedSymbol.swift
//  ios-template
//
//  SF Symbols 7 animated icon component with accessibility support.
//  Automatically falls back to static symbols on iOS 17 and respects Reduce Motion.
//

import SwiftUI

#if os(iOS)
    import UIKit
#endif

/// Animated SF Symbol with iOS 26 symbol effects
///
/// Features:
/// - SF Symbols 7 animated effects (.bounce, .pulse, .wiggle, .draw)
/// - Automatic fallback to static symbols on iOS 17
/// - Respects Reduce Motion accessibility setting
/// - Integrates with MotionStyle environment
///
/// Example usage:
/// ```swift
/// AnimatedSymbol(
///     "heart.fill",
///     effect: .bounce,
///     trigger: isFavorite
/// )
/// .foregroundColor(.red)
/// ```
public struct AnimatedSymbol: View {
    let systemName: String
    let effect: SymbolEffect
    let trigger: Bool
    let isActive: Bool

    @Environment(\.motionStyle) private var motionStyle

    public init(
        _ systemName: String,
        effect: SymbolEffect = .none,
        trigger: Bool = false,
        isActive: Bool = false
    ) {
        self.systemName = systemName
        self.effect = effect
        self.trigger = trigger
        self.isActive = isActive
    }

    public var body: some View {
        if shouldAnimate {
            animatedSymbol
        } else {
            staticSymbol
        }
    }

    // MARK: - Private Properties

    private var shouldAnimate: Bool {
        #if os(iOS)
            // Check all conditions for animation
            guard motionStyle.motionEnabled else { return false }
            guard !UIAccessibility.isReduceMotionEnabled else { return false }
            if #available(iOS 18.0, *) {
                return effect != .none
            }
            return false
        #else
            // macOS support (when available)
            return false
        #endif
    }

    @ViewBuilder
    private var animatedSymbol: some View {
        if #available(iOS 18.0, *) {
            switch effect {
            case .bounce:
                Image(systemName: systemName)
                    .symbolEffect(.bounce, value: trigger)

            case .pulse:
                Image(systemName: systemName)
                    .symbolEffect(.pulse, isActive: isActive)

            case .wiggle:
                Image(systemName: systemName)
                    .symbolEffect(.wiggle, value: trigger)

            case .variableColor:
                Image(systemName: systemName)
                    .symbolEffect(.variableColor, isActive: isActive)

            case .scale:
                Image(systemName: systemName)
                    .symbolEffect(.bounce, value: trigger)  // Use bounce for discrete scale effect

            case .appear:
                Image(systemName: systemName)
                    .symbolEffect(.pulse, isActive: isActive)  // Use pulse for continuous appear effect

            case .disappear:
                Image(systemName: systemName)
                    .symbolEffect(.pulse, isActive: !isActive)  // Use pulse inverse for disappear

            case .replace:
                Image(systemName: systemName)
                    .contentTransition(.symbolEffect(.replace))

            case .none:
                staticSymbol
            }
        } else {
            staticSymbol
        }
    }

    private var staticSymbol: some View {
        Image(systemName: systemName)
    }
}

// MARK: - Symbol Effect Types

public enum SymbolEffect {
    case none
    case bounce  // Brief bounce animation (favorite, like actions)
    case pulse  // Continuous pulsing (loading, progress)
    case wiggle  // Shake animation (delete, error, add to collection)
    case variableColor  // Color variation animation (download progress)
    case scale  // Scale up animation (selection, emphasis)
    case appear  // Appear animation (new item)
    case disappear  // Disappear animation (remove item)
    case replace  // Replace transition (icon change)
}

// MARK: - Convenience Initializers

extension AnimatedSymbol {
    /// Create a bouncing symbol for favorite/like actions
    public static func favorite(
        _ systemName: String,
        isFavorite: Bool
    ) -> AnimatedSymbol {
        AnimatedSymbol(
            systemName,
            effect: .bounce,
            trigger: isFavorite
        )
    }

    /// Create a pulsing symbol for loading states
    public static func loading(
        _ systemName: String,
        isLoading: Bool
    ) -> AnimatedSymbol {
        AnimatedSymbol(
            systemName,
            effect: .pulse,
            isActive: isLoading
        )
    }

    /// Create a wiggling symbol for delete/error actions
    public static func wiggle(
        _ systemName: String,
        trigger: Bool
    ) -> AnimatedSymbol {
        AnimatedSymbol(
            systemName,
            effect: .wiggle,
            trigger: trigger
        )
    }

    /// Create a variable color symbol for progress indication
    public static func progress(
        _ systemName: String,
        isActive: Bool
    ) -> AnimatedSymbol {
        AnimatedSymbol(
            systemName,
            effect: .variableColor,
            isActive: isActive
        )
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Symbol Effects") {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Bounce Effect")
                    .font(DesignSystem.Typography.labelMedium)

                HStack(spacing: DesignSystem.Spacing.lg) {
                    AnimatedSymbol.favorite("heart.fill", isFavorite: true)
                        .font(.system(size: 32))
                        .foregroundColor(.red)

                    AnimatedSymbol("star.fill", effect: .bounce, trigger: true)
                        .font(.system(size: 32))
                        .foregroundColor(.yellow)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Pulse Effect")
                    .font(DesignSystem.Typography.labelMedium)

                HStack(spacing: DesignSystem.Spacing.lg) {
                    AnimatedSymbol.loading("arrow.down.circle", isLoading: true)
                        .font(.system(size: 32))
                        .foregroundColor(DesignSystem.Colors.primary)

                    AnimatedSymbol.progress("wifi", isActive: true)
                        .font(.system(size: 32))
                        .foregroundColor(DesignSystem.Colors.info)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Wiggle Effect")
                    .font(DesignSystem.Typography.labelMedium)

                HStack(spacing: DesignSystem.Spacing.lg) {
                    AnimatedSymbol.wiggle("trash", trigger: true)
                        .font(.system(size: 32))
                        .foregroundColor(DesignSystem.Colors.error)

                    AnimatedSymbol("plus.circle", effect: .wiggle, trigger: true)
                        .font(.system(size: 32))
                        .foregroundColor(DesignSystem.Colors.success)
                }
            }

            Text("Note: Animations respect Reduce Motion")
                .font(DesignSystem.Typography.bodySmall)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.lg)
    }
#endif
