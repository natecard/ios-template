//
//  ListAppearModifier.swift
//  ios-template
//
// View modifier that applies a staggered appear animation to list items.
// Attempting to keep animations subtle and imply motion without being distracting.

import SwiftUI

// MARK: - List Appear Modifier
struct ListAppearModifier<ID: Hashable>: ViewModifier {
    @Environment(\.motionStyle) private var motionStyle

    let index: Int
    let id: ID

    @Binding var animatedIDs: Set<ID>

    @State private var isVisible = false
    @State private var animationTask: Task<Void, Never>?

    private var alreadyAnimated: Bool { animatedIDs.contains(id) }

    func body(content: Content) -> some View {
        let shouldAnimate =
            motionStyle.motionEnabled && !alreadyAnimated && index < motionStyle.maxStaggeredItems
        let offset = motionStyle.amplitude(12)

        return
            content
            .opacity(shouldAnimate ? (isVisible ? 1 : 0) : 1)
            .offset(y: shouldAnimate ? (isVisible ? 0 : offset) : 0)
            .onAppear { handleAppear(shouldAnimate: shouldAnimate) }
            .onDisappear { animationTask?.cancel() }
            .onChange(of: motionStyle.motionEnabled) {
                guard !motionStyle.motionEnabled else { return }
                animationTask?.cancel()
                if !alreadyAnimated {
                    animatedIDs.insert(id)
                }
                isVisible = true
            }
            .animation(motionStyle.quickSpring, value: isVisible)
    }

    private func handleAppear(shouldAnimate: Bool) {
        if alreadyAnimated {
            isVisible = true
            return
        }

        if !shouldAnimate {
            isVisible = true
            animatedIDs.insert(id)
            return
        }

        animationTask?.cancel()
        let delay = Double(index) * 0.05

        animationTask = Task { @MainActor in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }

            guard !Task.isCancelled else { return }

            animatedIDs.insert(id)
            isVisible = true
        }
    }
}

// MARK: - View Convenience
extension View {
    func listAppear<ID: Hashable>(index: Int, id: ID, animatedIDs: Binding<Set<ID>>) -> some View {
        modifier(ListAppearModifier(index: index, id: id, animatedIDs: animatedIDs))
    }
}
