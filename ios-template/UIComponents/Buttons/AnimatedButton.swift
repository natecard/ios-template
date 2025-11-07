//
//  AnimatedButton.swift
//  ios-template
//
// Animated button with scaling and haptic feedback.
//

import SwiftUI

#if os(iOS)
    import UIKit
#endif

struct AnimatedButton: ButtonStyle {
    let colour: Color
    let size: ButtonSize
    #if os(iOS)
        let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    #endif

    enum ButtonSize {
        case small, medium, large

        var padding: CGFloat {
            switch self {
            case .small: return DesignSystem.Spacing.sm
            case .medium: return DesignSystem.Spacing.md
            case .large: return DesignSystem.Spacing.lg
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return DesignSystem.BorderRadius.sm
            case .medium: return DesignSystem.BorderRadius.md
            case .large: return DesignSystem.BorderRadius.lg
            }
        }
    }

    #if os(iOS)
        init(
            colour: Color = DesignSystem.Colors.primary,
            size: ButtonSize = .medium,
            hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .soft
        ) {
            self.colour = colour
            self.size = size
            self.hapticStyle = hapticStyle
        }
    #else
        init(
            colour: Color = DesignSystem.Colors.primary,
            size: ButtonSize = .medium
        ) {
            self.colour = colour
            self.size = size
        }
    #endif

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(size.padding)
            .background(colour)
            .foregroundStyle(.white)
            .designCornerRadius(size.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .designShadow(DesignSystem.Shadows.small)
            .animation(DesignSystem.Animation.spring, value: configuration.isPressed)
            #if os(iOS)
                .onChange(of: configuration.isPressed) { _, isPressed in
                    if isPressed {
                        let generator = UIImpactFeedbackGenerator(style: hapticStyle)
                        generator.prepare()
                        generator.impactOccurred()
                    }
                }
            #endif
    }
}

// MARK: - Preview
#if DEBUG
    struct AnimatedButton_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: DesignSystem.Spacing.lg) {
                Button("Small Button") {}
                    .buttonStyle(AnimatedButton(colour: DesignSystem.Colors.primary, size: .small))

                Button("Medium Button") {}
                    .buttonStyle(AnimatedButton(colour: DesignSystem.Colors.success, size: .medium))

                Button("Large Button") {}
                    .buttonStyle(AnimatedButton(colour: DesignSystem.Colors.warning, size: .large))
            }
            .padding()
            .background(DesignSystem.Colors.background)
        }
    }
#endif
