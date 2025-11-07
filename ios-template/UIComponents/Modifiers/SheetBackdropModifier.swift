//
//  SheetBackdropModifier.swift
//  ios-template
//
//
//

import SwiftUI

// MARK: - Sheet Backdrop Modifier
struct SheetBackdropModifier: ViewModifier {
    @Environment(\.motionStyle) private var motionStyle

    let isPresented: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(backdropScale)
            .animation(motionStyle.modalSpring, value: isPresented)
            .animation(
                motionStyle.modalSpring,
                value: motionStyle.motionEnabled
            )
            .animation(
                motionStyle.modalSpring,
                value: motionStyle.intensity
            )
            .background(backdropOverlay)
    }

    private var backdropScale: CGFloat {
        guard motionStyle.motionEnabled else { return 1.0 }
        return isPresented ? 0.95 : 1.0
    }

    @ViewBuilder
    private var backdropOverlay: some View {
        if isPresented {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.85)
                .ignoresSafeArea()
                .transition(.opacity)
        }
    }
}

extension View {
    func withSheetBackdrop(isPresented: Bool) -> some View {
        modifier(SheetBackdropModifier(isPresented: isPresented))
    }
}
