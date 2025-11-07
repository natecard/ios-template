//
//  PressableRow.swift
//  ios-template
//
// Provides a pressable row effect with scaling and offset animations.
//

import SwiftUI

// MARK: - Pressable Row Wrapper
struct PressableRow<Content: View>: View {
    @Environment(\.motionStyle) private var motionStyle
    @State private var isPressed: Bool = false
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .scaleEffect(
                isPressed && motionStyle.motionEnabled
                    ? 1 - motionStyle.amplitude(motionStyle.pressScaleDownMagnitude)
                    : 1
            )
            .offset(
                y: isPressed && motionStyle.motionEnabled
                    ? motionStyle.amplitude(motionStyle.pressYOffsetPoints)
                    : 0
            )
            .animation(motionStyle.microSpring, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}
