## Animations (combined guidance)

Animations play a crucial role in creating a dynamic and engaging user interface. When implemented thoughtfully, they can guide users through the app, provide feedback, and make interactions feel more natural. The guidance below combines the README's concise principles with expanded implementation examples and Liquid Glass-specific recommendations so designers and engineers can pick patterns and implement them consistently.

### Best practices (concise)

1. **Purposeful Animations**: Ensure each animation has a clear role — draw attention to state changes, indicate progress, or provide feedback. Avoid decorative animations that distract.

2. **Consistency**: Use shared timing, curves, and tokens so animations feel part of the same system.

3. **Performance-first**: Minimize animated properties and prefer GPU-friendly operations. Avoid animating blur radius and large full-screen opacity stacks.

4. **Subtlety**: Keep amplitudes small and durations short for micro-interactions; reserve larger motion for clear context changes.

### High-level rules

- Animate cheap properties: transforms (translate, scale, rotate) and opacity on small layers are preferred.
- Trigger animations on explicit interactions or clear state changes — do not run heavy idle loops.
- Limit simultaneous animations (e.g., stagger only the first 8–12 rows) and debounce scroll or motion-driven effects.
- Test animations on lower-end hardware and provide simplified fallbacks for older devices.

### Core techniques & SwiftUI APIs (iOS 18+)

- Implicit / explicit SwiftUI animations: `animation`, `withAnimation` for state-driven motion.
- Spring animations: `spring(response: dampingFraction: blendDuration:)` for natural micro-interactions.
- `matchedGeometryEffect`: hero transitions and filter underlines.
- `contentTransition` / `.transition`: for insert/remove animations.
- Scroll geometry / `GeometryReader`: thumbnail parallax and small offset adjustments; throttle updates.
- PhaseAnimator / keyframe-style springs: for staged micro-interactions without timers.
- SF Symbols 7 enhancements (iOS 18+): Use `symbolEffect(.bounce)` or custom draw paths for icons. Example: Apply to download icons in `ItemFileButtons.swift` for tactile feedback without custom logic.

### Accessibility & feature gates

- If `Reduce Motion` is enabled: convert parallax and large transforms to fades or instant changes.
- If `Reduce Transparency` is enabled: replace animated materials with solid fills and avoid animating material properties.
- Offer `Settings → Motion` with options: `Off / Subtle / Full`. Use this setting to scale amplitudes and enable Liquid Glass extras where appropriate.
- Inclusive Design: Involve disability community feedback in testing (per WWDC 2025). Ensure animations don't conflict with screen readers—e.g., add pauses for VoiceOver in #8 (Bookmark Micro-Burst) to allow narration.

### Concrete, recommended patterns by component

#### Buttons and rows — micro-lift on press
- Purpose: tactile response to taps.
- Implementation: use `PressableButtonStyle` or wrap with `PressableRow` so lifts scale with `motionStyle` tokens.

#### Lists — appear fade-in/stagger
- Purpose: polished reveal and better perceived performance.
- Implementation: animate `opacity` + small Y offset with per-item delay (8–12ms). Limit to the first N visible rows and guard against re-triggering on reuse.

#### Cards — thumbnail parallax on scroll (optional)
- Purpose: depth while browsing.
- Implementation: Use iOS 17+ `ScrollView` with `scrollPosition` to trigger native animations without JS (Safari 19-inspired). Offset thumbnails by 0.08–0.12× scroll delta, clamped to ±12 pts; throttle to ~60–120 ms. Example in `ModernItemListView.swift`:
  ```swift
  ScrollView {
      LazyVStack {
          ForEach(items) { item in
              ItemCard(item)
                  .offset(y: scrollPosition * 0.1)  // Native scroll-driven offset
                  .animation(.easeOut, value: scrollPosition)
          }
      }
      .scrollPosition(id: \.id, anchor: .top)
  }
  ```
- Disable when `Reduce Motion` is true; leverages hardware acceleration for performance.

#### SegmentedControl — matched geometry underline
- Purpose: continuity between selected states.
- Implementation: `@Namespace` + `matchedGeometryEffect(id: "filterUnderline", in: namespace)` with a short spring (response 0.18–0.28, damping 0.86–0.95).

#### Search suggestions — insert/remove
- Purpose: graceful suggestion list updates.
- Implementation: use `.transition(.opacity.combined(with: .scale))` and `withAnimation(.easeInOut(duration: 0.20))` when changing the suggestions.

#### Sheet/Modal reveal
- Purpose: focus content (PDFs, settings) while keeping context.
- Implementation: present with `.sheet` / `.fullScreenCover`, animate content with `.scaleEffect(0.95)` + `.interactiveSpring(response: 0.4, dampingFraction: 0.75)`. Use system `Material` backdrops but avoid animating blur radius.
- Provide a `Simplify Glass` fallback that swaps material → solid fill under `Reduce Transparency` or on low-end hardware.

#### 7. PDF toolbar reveal
- Purpose: unobtrusive controls while reading.
- Implementation: slide Y by 8–12 pts with opacity and a short spring. Keep animations cheap.

#### 8. Bookmark / like micro-burst
- Purpose: delightful small-action feedback.
- Implementation: brief scale + small rotation or use SF Symbol `symbolEffect(.bounce)`, accompanied by haptic feedback. Keep amplitude low.

#### 9. Skeleton shimmer for loading
- Purpose: indicate loading without blocking the main thread.
- Implementation: animate a masked `LinearGradient` across placeholders (0.9–1.2s). Disable shimmer if `Reduce Motion`.

#### 10. Device-motion parallax (Liquid Glass — optional)
- Purpose: subtle depth for hero art on iOS 18+.
- Implementation: Sample `CMMotionManager` at a low rate, map small roll/pitch to ±2–4 pt offsets, and low-pass filter inputs. Allow opt-out and respect `Reduce Motion`. Enhance with Liquid Glass lensing: Apply subtle distortion to item cards in `ModernItemCard.swift` using `CALayer` corner curves and adaptive tints for focus effects. Example:
  ```swift
  .modifier(LiquidGlassLensingModifier(intensity: 0.05))  // Custom modifier for iOS 18+
  ```
  This bends light around content, improving readability without performance hit.

#### 11. Page transitions (PDF) — optional curl / 3D
- Purpose: book-like navigation for PDFs.
- Implementation: optional `UIView` with `CATransform3D` or `CABasicAnimation` on capable devices; fallback to a simple slide on lower-power devices.

#### 12. Cross-Document View Transitions (iOS 18.2+)
- Purpose: seamless navigation between item details or PDF pages with web-integrated content.
- Implementation: Use `NavigationStack` with iOS 18.2+ APIs for secure, same-origin transitions. Example in `MainTabView.swift`:
  ```swift
  NavigationStack {
      // Item list
  }
  .navigationTransition(.zoom)  // Native transition without JS
  ```
- Disable on older iOS; ensures secure transitions per dev.to guidelines.

### Example snippets

Filter underline (matched geometry):
```swift
@Namespace private var filterNamespace

HStack {
    ForEach(filters) { f in
        Text(f.title)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Group {
                    if selected == f.id {
                        Capsule()
                            .fill(DesignSystem.Colors.primary.opacity(0.12))
                            .matchedGeometryEffect(id: "filterUnderline", in: filterNamespace)
                    }
                }
            )
            .onTapGesture { withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) { selected = f.id } }
    }
}
```

List row press micro-lift:
```swift
struct PressableRow<Content: View>: View {
    @State private var isPressed = false
    let content: Content
    var body: some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1)
            .offset(y: isPressed ? 1 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.88), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}
```

Thumbnail parallax (simple):
```swift
GeometryReader { geo in
    Image(thumbnail)
        .offset(y: (geo.frame(in: .global).minY - baseY) * 0.08)
        .clipped()
}
```

Skeleton shimmer (guarded by Reduce Motion):
```swift
if !UIAccessibility.isReduceMotionEnabled {
    Rectangle()
        .fill(.linearGradient(...))
        .mask(skeletonShape)
        .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: animate)
}
```

### Performance guardrails

- Avoid animating large view hierarchies or many views at once. Prefer animating smaller sublayers.
- Do not animate blur radius or repeated full-screen opacity changes.
- Limit staggered reveals to the initial viewport (first 8–12 items) to keep CPU/GPU usage steady.
- Debounce scroll-driven or motion-driven animations; sample less frequently and low-pass filter inputs.

### Platform & Liquid Glass guidance (iOS 18+)

- Use Liquid Glass as an accent: small dynamic tinting, micro-parallax, and layered materials. Keep chroma/tint breathing subtle (opacity deltas 0.02–0.08) and debounce to avoid rapid color shifts.
- Provide a `Simplify Glass` user option (or honor `Reduce Transparency`) that reduces tint, removes parallax, and swaps materials for solid fills on lower-end devices.
- Centralize animation amplitudes and timings in a `MotionIntensity` / `MotionStyle` token inside `DesignSystem` so components read a consistent set of animation parameters.
- For app widgets (if applicable): Leverage WidgetKit updates (iOS 18+) with Clear Glass and Accented Tint for elevated/recessed styles. Apply subtle scale effects in widget previews for a refreshed look.

### Testing checklist

- Verify 60 fps on an iOS 18 device (older model) for key screens.
- Test `Reduce Motion` and `Reduce Transparency` toggles and app-level `MotionIntensity` settings.
- Validate Liquid Glass simplification on iOS 18+ and ensure quick fallback on lower-end devices.
- Confirm accessibility labels and interaction timing still feel correct when animations are disabled.
- Inclusive Testing: Gather feedback from users with disabilities (e.g., via user testing sessions) to ensure animations enhance rather than hinder accessibility.

### WWDC 2025 Features Integration

These ideas incorporate advancements from WWDC 2025 (focusing on iOS 18+ for compatibility):

- **SF Symbols 7**: Use for interactive icons (e.g., in `ItemFileButtons.swift`). Implement with `.symbolEffect(.bounce)` for download feedback.
- **Liquid Glass Lensing**: Apply to `ModernItemCard.swift` for focus effects. Create a custom modifier for subtle distortions.
- **Scroll-Driven Animations**: Enhance #3 in `ModernItemListView.swift` with `.scrollPosition` for native triggers.
- **Cross-Document Transitions**: Add to `MainTabView.swift` with `.navigationTransition(.zoom)` for seamless item navigation.
- **WidgetKit**: If widgets exist, use Clear Glass tints for elevated styles.
- **Inclusive Design**: Prioritize user testing with diverse groups for all patterns.

### Next steps (developer guidance)

- Add `MotionStyle`