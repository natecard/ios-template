//
//  DesignSystem.swift
//  ios-template
//
// Centralized design system for consistent styling across the app.
//

import SwiftUI

// Platform-specific imports
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

// MARK: - Design System

/// Centralized design system for consistent app-wide styling
/// - Colors: Vibrant, accessible color palette with semantic meaning
/// - Typography: Consistent font sizes and weights
/// - Spacing: Standardized spacing values
/// - Border Radius: Consistent corner radius values
/// - Shadows: Subtle shadow definitions
/// - Animations: Standardized animation durations and curves
/// - Motion Style Tokens: Centralized animation durations, spring parameters, and intensity levels
struct DesignSystem {

    // MARK: - Colors
    struct Colors {
        // Use environment's color scheme for adaptive colors
        private static func adaptiveColor(light: Color, dark: Color) -> Color {
            Color(
                UIColor { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return UIColor(dark)
                    default:
                        return UIColor(light)
                    }
                }
            )
        }

        // Primary brand colors - Adaptive teal/cyan palette
        // Change as needed to fit brand identity, ensuring proper contrast and accessibility standards
        static let primary: Color = adaptiveColor(
            light: Color(red: 0.2, green: 0.6, blue: 0.8),  // Vibrant teal
            dark: Color(red: 0.4, green: 0.75, blue: 0.9)  // Light teal for dark mode
        )
        static let primaryLight: Color = adaptiveColor(
            light: Color(red: 0.4, green: 0.75, blue: 0.9),  // Light teal
            dark: Color(red: 0.6, green: 0.85, blue: 0.95)  // Even lighter for dark mode
        )
        static let primaryDark: Color = adaptiveColor(
            light: Color(red: 0.1, green: 0.45, blue: 0.7),  // Dark teal
            dark: Color(red: 0.05, green: 0.3, blue: 0.55)  // Darker for dark mode
        )

        // Secondary colors - Adaptive warm coral accent
        // Complementary to primary colors for highlights and accents
        // Ensure sufficient contrast in both light and dark modes
        static let secondary: Color = adaptiveColor(
            light: Color(red: 0.95, green: 0.4, blue: 0.3),  // Warm coral
            dark: Color(red: 0.85, green: 0.5, blue: 0.4)  // Softer coral for dark mode
        )
        static let secondaryLight: Color = adaptiveColor(
            light: Color(red: 0.98, green: 0.6, blue: 0.5),  // Light coral
            dark: Color(red: 0.9, green: 0.7, blue: 0.6)  // Adjusted for dark mode
        )
        static let secondaryDark: Color = adaptiveColor(
            light: Color(red: 0.85, green: 0.3, blue: 0.2),  // Dark coral
            dark: Color(red: 0.75, green: 0.2, blue: 0.1)  // Darker for dark mode
        )

        // Accent colors - Adaptive complementary palette
        // Used sparingly for highlights and interactive elements
        static let accent: Color = adaptiveColor(
            light: Color(red: 0.6, green: 0.4, blue: 0.9),  // Soft purple
            dark: Color(red: 0.7, green: 0.5, blue: 1.0)  // Lighter purple for dark mode
        )
        static let accentLight: Color = adaptiveColor(
            light: Color(red: 0.75, green: 0.6, blue: 0.95),  // Light purple
            dark: Color(red: 0.85, green: 0.7, blue: 1.0)  // Adjusted for dark mode
        )
        static let accentDark: Color = adaptiveColor(
            light: Color(red: 0.45, green: 0.25, blue: 0.75),  // Dark purple
            dark: Color(red: 0.35, green: 0.15, blue: 0.65)  // Darker for dark mode
        )

        // Semantic colors - Adaptive for better visual hierarchy
        // Provide clear meaning for status indicators and feedback
        static let success: Color = adaptiveColor(
            light: Color(red: 0.2, green: 0.7, blue: 0.4),  // Fresh green
            dark: Color(red: 0.3, green: 0.8, blue: 0.5)  // Brighter green for dark mode
        )
        static let warning: Color = adaptiveColor(
            light: Color(red: 0.95, green: 0.6, blue: 0.1),  // Warm amber
            dark: Color(red: 1.0, green: 0.7, blue: 0.2)  // Brighter amber for dark mode
        )
        static let error: Color = adaptiveColor(
            light: Color(red: 0.9, green: 0.25, blue: 0.35),  // Vibrant red
            dark: Color(red: 1.0, green: 0.4, blue: 0.5)  // Brighter red for dark mode
        )
        static let info: Color = adaptiveColor(
            light: Color(red: 0.3, green: 0.6, blue: 0.9),  // Bright blue
            dark: Color(red: 0.4, green: 0.7, blue: 1.0)  // Brighter blue for dark mode
        )

        // Neutral colors - Adaptive warm grays
        static let neutral: Color = adaptiveColor(
            light: Color(red: 0.45, green: 0.45, blue: 0.5),  // Warm gray
            dark: Color(red: 0.6, green: 0.6, blue: 0.65)  // Lighter gray for dark mode
        )
        static let neutralLight: Color = adaptiveColor(
            light: Color(red: 0.65, green: 0.65, blue: 0.7),  // Light warm gray
            dark: Color(red: 0.75, green: 0.75, blue: 0.8)  // Lighter for dark mode
        )
        static let neutralDark: Color = adaptiveColor(
            light: Color(red: 0.25, green: 0.25, blue: 0.3),  // Dark warm gray
            dark: Color(red: 0.15, green: 0.15, blue: 0.2)  // Darker for dark mode
        )

        // Background colors - Adaptive subtle warmth
        // Provide comfortable reading experience in both light and dark modes
        static let background: Color = {
            #if os(iOS)
                return Color(.systemBackground)
            #elseif os(macOS)
                return Color(nsColor: .controlBackgroundColor)
            #else
                return Color.white  // fallback
            #endif
        }()
        static let secondaryBackground: Color = adaptiveColor(
            light: Color(red: 0.98, green: 0.97, blue: 0.99),  // Very light warm tint
            dark: Color(red: 0.05, green: 0.05, blue: 0.07)  // Darker background for dark mode
        )
        static let tertiaryBackground: Color = adaptiveColor(
            light: Color(red: 0.95, green: 0.94, blue: 0.96),  // Light warm tint
            dark: Color(red: 0.1, green: 0.1, blue: 0.13)  // Darker background for dark mode
        )

        // Surface colors - Adaptive with subtle warmth
        static let surface: Color = {
            #if os(iOS)
                return Color(.systemBackground)
            #elseif os(macOS)
                return Color(nsColor: .controlBackgroundColor)
            #else
                return Color.white  // fallback
            #endif
        }()
        static let surfaceSecondary: Color = adaptiveColor(
            light: Color(red: 0.98, green: 0.97, blue: 0.99),  // Very light warm tint
            dark: Color(red: 0.1, green: 0.1, blue: 0.12)  // Darker surface for dark mode
        )
        static let surfaceTertiary: Color = adaptiveColor(
            light: Color(red: 0.95, green: 0.94, blue: 0.96),  // Light warm tint
            dark: Color(red: 0.15, green: 0.15, blue: 0.18)  // Darker surface for dark mode
        )

        // Border colors - Adaptive warm and subtle
        static let border: Color = adaptiveColor(
            light: Color(red: 0.9, green: 0.89, blue: 0.92),  // Warm border
            dark: Color(red: 0.25, green: 0.25, blue: 0.28)  // Darker border for dark mode
        )
        static let borderLight: Color = adaptiveColor(
            light: Color(red: 0.94, green: 0.93, blue: 0.96),  // Light warm border
            dark: Color(red: 0.2, green: 0.2, blue: 0.23)  // Darker border for dark mode
        )

        // Text colors - Adaptive enhanced contrast
        static let textPrimary: Color = {
            #if os(iOS)
                return Color(.label)
            #elseif os(macOS)
                return Color(nsColor: .labelColor)
            #else
                return Color.black  // fallback
            #endif
        }()
        static let textSecondary: Color = adaptiveColor(
            light: Color(red: 0.4, green: 0.4, blue: 0.45),  // Warm secondary text
            dark: Color(red: 0.6, green: 0.6, blue: 0.65)  // Lighter text for dark mode
        )
        static let textTertiary: Color = adaptiveColor(
            light: Color(red: 0.55, green: 0.55, blue: 0.6),  // Warm tertiary text
            dark: Color(red: 0.7, green: 0.7, blue: 0.75)  // Lighter text for dark mode
        )
        static let textQuaternary: Color = adaptiveColor(
            light: Color(red: 0.7, green: 0.7, blue: 0.75),  // Warm quaternary text
            dark: Color(red: 0.8, green: 0.8, blue: 0.85)  // Lighter text for dark mode
        )

        // Special purpose colors - Adaptive
        static let highlight: Color = adaptiveColor(
            light: Color(red: 1.0, green: 0.95, blue: 0.7),  // Soft yellow highlight
            dark: Color(red: 0.8, green: 0.7, blue: 0.4)  // Darker yellow for dark mode
        )
        static let highlightText: Color = adaptiveColor(
            light: Color(red: 0.6, green: 0.5, blue: 0.1),  // Dark yellow text
            dark: Color(red: 0.9, green: 0.8, blue: 0.3)  // Lighter yellow for dark mode
        )
        static let link: Color = adaptiveColor(
            light: Color(red: 0.2, green: 0.6, blue: 0.8),  // Primary color for links
            dark: Color(red: 0.4, green: 0.75, blue: 0.9)  // Lighter link color for dark mode
        )
        static let code: Color = adaptiveColor(
            light: Color(red: 0.95, green: 0.97, blue: 1.0),  // Light blue for code blocks
            dark: Color(red: 0.1, green: 0.12, blue: 0.15)  // Darker background for code in dark mode
        )
        static let codeText: Color = adaptiveColor(
            light: Color(red: 0.2, green: 0.3, blue: 0.4),  // Dark blue for code text
            dark: Color(red: 0.8, green: 0.85, blue: 0.9)  // Lighter text for dark mode
        )

        // Utility colors
        static let clear = Color.clear
        static let white = Color.white
        static let black = Color.black
        
        // Liquid Glass tints - iOS 26
        static let glassTint: Color = adaptiveColor(
            light: Color(red: 0.98, green: 0.98, blue: 0.99).opacity(0.7),  // Subtle light tint
            dark: Color(red: 0.08, green: 0.08, blue: 0.1).opacity(0.7)     // Subtle dark tint
        )
        static let glassOverlay: Color = adaptiveColor(
            light: Color.white.opacity(0.3),
            dark: Color.black.opacity(0.3)
        )
    }

    // MARK: - Typography
    struct Typography {
        // Display styles
        // Large sizes for prominent headings
        static let displayLarge = Font.system(size: 57, weight: .regular, design: .default)
        static let displayMedium = Font.system(size: 45, weight: .regular, design: .default)
        static let displaySmall = Font.system(size: 36, weight: .regular, design: .default)

        // Headline styles
        // Bold and attention-grabbing for section titles
        static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .default)
        static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .default)
        static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .default)

        // Title styles
        // Medium emphasis for section titles
        static let titleLarge = Font.system(size: 22, weight: .semibold, design: .default)
        static let titleMedium = Font.system(size: 16, weight: .semibold, design: .default)
        static let titleSmall = Font.system(size: 14, weight: .semibold, design: .default)

        // Body styles
        // Standard text for paragraphs and content
        static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

        // Label styles
        // Smaller text for captions and labels
        static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
        static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
        static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
    }

    // MARK: - Spacing
    // Standardized spacing values for consistent layout
    // iOS 26 updates: Added xxs for tight layouts
    struct Spacing {
        static let xxs: CGFloat = 2  // iOS 26: Tight layouts
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: - Gaps
    // Standardized gap values for consistent layout
    struct Gaps {
        static let sm: CGFloat = 175
        static let md: CGFloat = 250
        static let lg: CGFloat = 300
        static let xl: CGFloat = 350
    }

    // MARK: - Heights
    // Standardized height values for consistent layout
    struct Heights {
        static let sm: CGFloat = 175
        static let md: CGFloat = 250
        static let lg: CGFloat = 350
        static let xl: CGFloat = 400
    }
    // MARK: - Border Radius
    // Consistent corner radius values for UI elements
    // iOS 26 updates: Increased values for modern, softer appearance
    struct BorderRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16      // iOS 26: Updated from 12
        static let lg: CGFloat = 20      // iOS 26: Updated from 16
        static let xl: CGFloat = 28      // iOS 26: Updated from 24
        static let xxl: CGFloat = 36     // iOS 26: New larger radius
        static let full: CGFloat = 999
    }

    // MARK: - Shadows
    // Standardized shadow definitions for depth and elevation
    // iOS 26 updates: Softer, more diffused shadows with increased radius and reduced opacity
    struct Shadows {
        static let small = Shadow(
            color: Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.06),  // iOS 26: Reduced opacity
            radius: 4,   // iOS 26: Increased radius
            x: 0,
            y: 2         // iOS 26: Increased offset
        )
        static let medium = Shadow(
            color: Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.08),  // iOS 26: Reduced opacity
            radius: 8,   // iOS 26: Increased radius
            x: 0,
            y: 4         // iOS 26: Increased offset
        )
        static let large = Shadow(
            color: Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.10),  // iOS 26: Reduced opacity
            radius: 16,  // iOS 26: Increased radius
            x: 0,
            y: 6         // iOS 26: Increased offset
        )
        static let xlarge = Shadow(
            color: Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.12),  // iOS 26: New extra large shadow
            radius: 24,
            x: 0,
            y: 8
        )
    }

    // MARK: - Animation
    // Common animation presets for consistent motion design
    struct Animation {
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let normal = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.interactiveSpring(duration: 0.3)
    }

    // MARK: - Liquid Glass Materials (iOS 26)
    // Depth-aware blur and vibrancy effects with elevation levels
    enum GlassElevation {
        case base        // Standard surface level
        case elevated    // Slightly raised (cards, buttons)
        case floating    // Floating above content (sheets, popovers)
        case overlay     // Top-most layer (alerts, modals)
        
        var blurRadius: CGFloat {
            switch self {
            case .base: return 8
            case .elevated: return 12
            case .floating: return 16
            case .overlay: return 20
            }
        }
        
        var tintOpacity: Double {
            switch self {
            case .base: return 0.5
            case .elevated: return 0.6
            case .floating: return 0.7
            case .overlay: return 0.8
            }
        }
        
        var shadow: Shadow {
            switch self {
            case .base: return Shadows.small
            case .elevated: return Shadows.medium
            case .floating: return Shadows.large
            case .overlay: return Shadows.xlarge
            }
        }
    }
    
    // MARK: - Motion Style Tokens
    // Centralized motion style tokens for consistent animation behavior
    enum Intensity: String, Equatable {
        case off
        case subtle
        case full
    }
    struct MotionStyle: Equatable {

        // User/feature controls
        var intensity: Intensity

        // Tunable tokens (use via environment)
        var maxStaggeredItems: Int
        var parallaxAmplitudePoints: CGFloat
        var parallaxClampPoints: CGFloat
        var scrollThrottleMs: Int
        var shimmerDuration: Double
        // Press interaction tokens
        var pressScaleDownMagnitude: CGFloat  // e.g., 0.02 => scales to 0.98
        var pressYOffsetPoints: CGFloat  // e.g., 1 pt micro-lift

        // Common animations
        var microSpring: SwiftUI.Animation
        var quickSpring: SwiftUI.Animation
        var modalSpring: SwiftUI.Animation
        var fade: SwiftUI.Animation

        // Derived gates (system gating is applied upstream by MotionSettings)
        var motionEnabled: Bool { intensity != .off }

        // Scale an amplitude by current intensity and gates
        func amplitude(_ base: CGFloat) -> CGFloat {
            guard motionEnabled else { return 0 }
            switch intensity {
            case .off: return 0
            case .subtle: return base * 0.5
            case .full: return base
            }
        }

        // Default initializer choosing safe, platform-aware defaults
        init(
            intensity: Intensity? = nil,
        ) {
            // System accessibility gates are handled by MotionSettings.
            self.intensity = intensity ?? .full

            // Token defaults (amplitudes scaled by intensity at call sites via amplitude(_:))
            self.maxStaggeredItems = 10
            self.parallaxAmplitudePoints = 12
            self.parallaxClampPoints = 12
            self.scrollThrottleMs = 90
            self.shimmerDuration = 1.0
            // Press defaults
            self.pressScaleDownMagnitude = 0.02
            self.pressYOffsetPoints = 1

            // Animation defaults
            self.microSpring = .spring(response: 0.18, dampingFraction: 0.88)
            self.quickSpring = .spring(response: 0.22, dampingFraction: 0.9)
            self.modalSpring = .interactiveSpring(response: 0.4, dampingFraction: 0.75)
            self.fade = .easeInOut(duration: 0.2)
        }
    }
}

// MARK: - Shadow Model
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    /// Apply a shadow from the design system
    func designShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    /// Apply standard padding from the design system
    func designPadding(_ edges: Edge.Set = .all, _ spacing: CGFloat) -> some View {
        self.padding(edges, spacing)
    }

    /// Apply standard corner radius from the design system
    func designCornerRadius(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

// MARK: - Motion Style Environment
private struct MotionStyleKey: EnvironmentKey {
    static let defaultValue: DesignSystem.MotionStyle = DesignSystem.MotionStyle()
}

extension EnvironmentValues {
    var motionStyle: DesignSystem.MotionStyle {
        get { self[MotionStyleKey.self] }
        set { self[MotionStyleKey.self] = newValue }
    }
}

extension View {
    /// Inject a `DesignSystem.MotionStyle` for this view hierarchy
    func motionStyle(_ style: DesignSystem.MotionStyle) -> some View {
        environment(\.motionStyle, style)
    }
    
    /// Apply Liquid Glass material effect with elevation-based depth
    /// Automatically falls back to solid color with opacity on iOS 17 and earlier
    /// Respects Reduce Transparency accessibility setting
    @ViewBuilder
    func liquidGlass(
        _ elevation: DesignSystem.GlassElevation = .elevated,
        tint: Color? = nil
    ) -> some View {
        if #available(iOS 18.0, *) {
            #if os(iOS)
            // Check for Reduce Transparency accessibility setting
            if UIAccessibility.isReduceTransparencyEnabled {
                // Fallback to solid color for accessibility
                self
                    .background(DesignSystem.Colors.surface)
                    .designShadow(elevation.shadow)
            } else {
                // Full Liquid Glass effect with materials
                self
                    .background(
                        ZStack {
                            // Base material blur
                            Rectangle()
                                .fill(.ultraThinMaterial)
                            
                            // Tint overlay
                            (tint ?? DesignSystem.Colors.glassTint)
                                .opacity(elevation.tintOpacity)
                            
                            // Subtle overlay for depth
                            DesignSystem.Colors.glassOverlay
                        }
                    )
                    .designShadow(elevation.shadow)
            }
            #else
            // macOS fallback
            self
                .background(
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                        (tint ?? DesignSystem.Colors.glassTint)
                            .opacity(elevation.tintOpacity)
                    }
                )
                .designShadow(elevation.shadow)
            #endif
        } else {
            // iOS 17 and earlier fallback - solid color with opacity
            self
                .background(
                    DesignSystem.Colors.surface
                        .opacity(0.95)
                )
                .designShadow(elevation.shadow)
        }
    }
}
