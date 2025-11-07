//
//  ModernSearchBar.swift
//  ios-template
//
//  Modern search bar component with suggestions dropdown.
//

import SwiftUI

struct ModernSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: () -> Void
    let onClear: () -> Void
    let showSuggestions: Bool
    let suggestions: [String]
    let onSuggestionTap: ((String) -> Void)?

    @FocusState private var isFocused: Bool
    @State private var isEditing = false
    @Environment(\.motionStyle) private var motionStyle

    init(
        text: Binding<String>,
        placeholder: String = "Search items...",
        showSuggestions: Bool = false,
        suggestions: [String] = [],
        onSuggestionTap: ((String) -> Void)? = nil,
        onSearch: @escaping () -> Void = {},
        onClear: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.showSuggestions = showSuggestions
        self.suggestions = suggestions
        self.onSuggestionTap = onSuggestionTap
        self.onSearch = onSearch
        self.onClear = onClear
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main search bar
            HStack(spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .font(.system(size: 16, weight: .medium))

                    TextField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .focused($isFocused)
                        .onSubmit {
                            onSearch()
                        }
                        .onChange(of: text) { _, newValue in
                            isEditing = !newValue.isEmpty
                        }

                    if isEditing {
                        Button(action: {
                            withOptionalMotion(motionStyle.fade) {
                                text = ""
                                isEditing = false
                            }
                            onClear()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.secondaryBackground)
                .designCornerRadius(DesignSystem.BorderRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.md)
                        .stroke(
                            isFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
                            lineWidth: isFocused ? 2 : 1
                        )
                )

                if isEditing {
                    Button("Search") {
                        onSearch()
                        isFocused = false
                    }
                    .font(DesignSystem.Typography.labelMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .animation(motionStyle.motionEnabled ? motionStyle.fade : nil, value: isEditing)
            .animation(motionStyle.motionEnabled ? motionStyle.fade : nil, value: isFocused)

            // Suggestions dropdown
            if showSuggestions && !suggestions.isEmpty && isFocused {
                VStack(spacing: 0) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: {
                            withOptionalMotion(motionStyle.fade) {
                                text = suggestion
                                isFocused = false
                            }
                            onSuggestionTap?(suggestion)
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                    .font(.system(size: 14, weight: .medium))

                                Text(suggestion)
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                    .multilineTextAlignment(.leading)

                                Spacer()
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .background(DesignSystem.Colors.surface)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if suggestion != suggestions.last {
                            Divider()
                                .background(DesignSystem.Colors.borderLight)
                                .padding(.leading, DesignSystem.Spacing.xl)
                        }
                    }
                }
                .background(DesignSystem.Colors.surface)
                .designCornerRadius(DesignSystem.BorderRadius.md)
                .designShadow(DesignSystem.Shadows.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.md)
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                )
                .transition(suggestionsTransition)
                .animation(motionStyle.motionEnabled ? motionStyle.fade : nil, value: isFocused)
                .animation(motionStyle.motionEnabled ? motionStyle.fade : nil, value: suggestions)
            }
        }
    }

    // MARK: - Optional Motion
    private func withOptionalMotion(_ animation: Animation, actions: () -> Void) {
        if motionStyle.motionEnabled {
            withAnimation(animation) { actions() }
        } else {
            actions()
        }
    }

    // MARK: - Suggestions Transition
    private var suggestionsTransition: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
    }
}

// MARK: - Preview
#if DEBUG
    struct ModernSearchBar_Previews: PreviewProvider {
        @State static var searchText = ""

        static var previews: some View {
            VStack(spacing: DesignSystem.Spacing.lg) {
                ModernSearchBar(
                    text: $searchText,
                    placeholder: "Search items...",
                    showSuggestions: true,
                    suggestions: [
                        "machine learning",
                        "artificial intelligence",
                        "computer vision",
                        "natural language processing",
                    ]
                ) { _ in
                    print("Search tapped")
                }

                ModernSearchBar(
                    text: $searchText,
                    placeholder: "Simple search..."
                ) { _ in
                    print("Search tapped")
                }
            }
            .padding()
            .background(DesignSystem.Colors.background)
        }
    }
#endif
