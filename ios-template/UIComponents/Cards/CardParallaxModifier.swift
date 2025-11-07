//
//  CardParallaxModifier.swift
//  ios-template
//
// View modifier that applies a motion-style-aware parallax effect to cards.
// Provides a subtle vertical offset based on scroll position to enhance depth perception.

import QuartzCore
import SwiftUI

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

// MARK: - Preference Key
private struct CardParallaxPreferenceKey: PreferenceKey {
    static var defaultValue: [AnyHashable: CGFloat] { [:] }

    static func reduce(value: inout [AnyHashable: CGFloat], nextValue: () -> [AnyHashable: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - Parallax Modifier
struct CardParallaxModifier<ID: Hashable>: ViewModifier {
    @Environment(\.motionStyle) private var motionStyle

    let id: ID
    let amplitudeOverride: CGFloat?

    @State private var parallaxOffset: CGFloat = 0
    @State private var lastUpdate: CFTimeInterval = 0

    func body(content: Content) -> some View {
        content
            .offset(y: motionStyle.motionEnabled ? parallaxOffset : 0)
            .background(reader)
            .onPreferenceChange(CardParallaxPreferenceKey.self, perform: updateParallax(with:))
            .onChange(of: motionStyle.motionEnabled) {
                if !motionStyle.motionEnabled {
                    parallaxOffset = 0
                }
            }
            .onDisappear { parallaxOffset = 0 }
    }

    private var reader: some View {
        GeometryReader { proxy in
            let midY = proxy.frame(in: .global).midY
            Color.clear.preference(key: CardParallaxPreferenceKey.self, value: [AnyHashable(id): midY])
        }
    }

    private func updateParallax(with values: [AnyHashable: CGFloat]) {
        guard motionStyle.motionEnabled,
            let midY = values[AnyHashable(id)]
        else {
            parallaxOffset = 0
            return
        }

        let now = CACurrentMediaTime()
        let throttle = max(0.0, Double(motionStyle.scrollThrottleMs) / 1000.0)

        if now - lastUpdate < throttle {
            return
        }
        lastUpdate = now

        let amplitude = motionStyle.amplitude(amplitudeOverride ?? motionStyle.parallaxAmplitudePoints)
        guard amplitude > 0 else {
            parallaxOffset = 0
            return
        }

        let screenBounds = currentScreenBounds()
        let screenMid = screenBounds.midY
        let screenHeight = max(screenBounds.height, 1)

        let distance = screenMid - midY
        let normalized = distance / screenHeight
        let clampedNormalized = max(-1, min(1, normalized))
        let rawOffset = clampedNormalized * amplitude
        let clamp = motionStyle.parallaxClampPoints
        let clampedOffset = min(max(rawOffset, -clamp), clamp)

        withAnimation(motionStyle.quickSpring) {
            parallaxOffset = clampedOffset
        }
    }

    private func currentScreenBounds() -> CGRect {
        #if os(iOS)
            // iOS 26+: Get screen from scene context (preferred over deprecated UIScreen.main)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                return windowScene.screen.bounds
            }
            // Fallback: Use sensible defaults if no scene is available (edge case)
            return CGRect(x: 0, y: 0, width: 393, height: 852)  // iPhone 15 Pro dimensions
        #elseif os(macOS)
            NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
        #else
            CGRect(x: 0, y: 0, width: 1024, height: 768)
        #endif
    }
}

// MARK: - Convenience
extension View {
    /// Applies a motion-style-aware parallax offset that responds to scroll position.
    func cardParallax<ID: Hashable>(id: ID, amplitude: CGFloat? = nil) -> some View {
        modifier(CardParallaxModifier(id: id, amplitudeOverride: amplitude))
    }
}
