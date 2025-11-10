//
//  InputComponents.swift
//  ios-template
//
// Components for various input controls used throughout the app.
//

import SwiftUI

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: () -> Void
    let onClear: () -> Void

    @FocusState private var isFocused: Bool
    @State private var isEditing = false

    init(
        text: Binding<String>,
        placeholder: String = "Search...",
        onSearch: @escaping () -> Void = {},
        onClear: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearch = onSearch
        self.onClear = onClear
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .font(.system(size: 16, weight: .medium))

                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(.black)  // Force readable text color regardless of theme
                    .focused($isFocused)
                    .onSubmit {
                        onSearch()
                    }
                    .onChange(of: text) { _, newValue in
                        isEditing = !newValue.isEmpty
                    }

                if isEditing {
                    Button(action: {
                        text = ""
                        isEditing = false
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
        .animation(DesignSystem.Animation.fast, value: isEditing)
        .animation(DesignSystem.Animation.fast, value: isFocused)
    }
}

// MARK: - Text Input Field
#if os(iOS)
    struct TextInputField: View {
        let title: String?
        let placeholder: String
        @Binding var text: String
        let isRequired: Bool
        let errorMessage: String?
        let keyboardType: UIKeyboardType
        let textContentType: UITextContentType?

        @FocusState private var isFocused: Bool

        init(
            title: String? = nil,
            placeholder: String = "",
            text: Binding<String>,
            isRequired: Bool = false,
            errorMessage: String? = nil,
            keyboardType: UIKeyboardType = .default,
            textContentType: UITextContentType? = nil
        ) {
            self.title = title
            self.placeholder = placeholder
            self._text = text
            self.isRequired = isRequired
            self.errorMessage = errorMessage
            self.keyboardType = keyboardType
            self.textContentType = textContentType
        }

        var body: some View {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                if let title = title {
                    HStack {
                        Text(title)
                            .font(DesignSystem.Typography.labelMedium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        if isRequired {
                            Text("*")
                                .font(DesignSystem.Typography.labelMedium)
                                .foregroundColor(DesignSystem.Colors.error)
                        }
                    }
                }

                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(.black)  // Force readable text color regardless of theme
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .designCornerRadius(DesignSystem.BorderRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.sm)
                            .stroke(
                                errorMessage != nil
                                    ? DesignSystem.Colors.error
                                    : isFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
                                lineWidth: errorMessage != nil || isFocused ? 2 : 1
                            )
                    )
                    .focused($isFocused)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(DesignSystem.Typography.labelSmall)
                        .foregroundColor(DesignSystem.Colors.error)
                        .padding(.leading, DesignSystem.Spacing.sm)
                }
            }
        }
    }
#endif
// MARK: - Segmented Control
struct SegmentedControl<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    let titleProvider: (T) -> String
    let iconProvider: ((T) -> String)?
    @Environment(\.motionStyle) private var motionStyle
    @Namespace private var selectionNamespace

    init(
        options: [T],
        selection: Binding<T>,
        titleProvider: @escaping (T) -> String,
        iconProvider: ((T) -> String)? = nil
    ) {
        self.options = options
        self._selection = selection
        self.titleProvider = titleProvider
        self.iconProvider = iconProvider
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                let isSelected = selection == option

                Button(action: {
                    withAnimation(motionStyle.quickSpring) { selection = option }
                }) {
                    buttonContent(for: option, isSelected: isSelected)
                }
                .buttonStyle(.plain)

                if index < options.count - 1 {
                    Divider()
                        .frame(height: 20)
                        .opacity(0.3)
                }
            }
        }
        .background(DesignSystem.Colors.secondaryBackground)
        .designCornerRadius(DesignSystem.BorderRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.sm)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
        .animation(motionStyle.quickSpring, value: selection)
    }

    @ViewBuilder
    private func buttonContent(for option: T, isSelected: Bool) -> some View {
        ZStack {
            if isSelected {
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.sm)
                    .fill(DesignSystem.Colors.primary)
                    .matchedGeometryEffect(id: "SegmentedControlHighlight", in: selectionNamespace)
            }

            HStack(spacing: DesignSystem.Spacing.xs) {
                if let iconProvider = iconProvider {
                    Image(systemName: iconProvider(option))
                        .font(.system(size: 14, weight: .medium))
                }

                Text(titleProvider(option))
                    .font(DesignSystem.Typography.labelMedium)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Toggle Switch
struct ToggleSwitch: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    let onToggle: ((Bool) -> Void)?
    let isDisabled: Bool

    init(
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>,
        onToggle: ((Bool) -> Void)? = nil,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.onToggle = onToggle
        self.isDisabled = isDisabled
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(
                        isDisabled ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textPrimary
                    )

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .disabled(isDisabled)
                .onChange(of: isOn) { _, newValue in
                    onToggle?(newValue)
                }
                .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primary))
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Slider Input
struct SliderInput: View {
    let title: String
    let subtitle: String?
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let valueFormatter: ((Double) -> String)?

    init(
        title: String,
        subtitle: String? = nil,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        valueFormatter: ((Double) -> String)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self._value = value
        self.range = range
        self.step = step
        self.valueFormatter = valueFormatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Typography.bodySmall)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }

                Spacer()

                Text(valueFormatter?(value) ?? String(format: "%.1f", value))
                    .font(DesignSystem.Typography.labelMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .fontWeight(.semibold)
            }

            Slider(value: $value, in: range, step: step)
                .accentColor(DesignSystem.Colors.primary)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Preview
#if DEBUG
    struct InputComponents_Previews: PreviewProvider {
        @State static var searchText = ""
        @State static var inputText = ""
        @State static var selectedOption = "Option 1"
        @State static var isToggled = false
        @State static var sliderValue = 50.0

        static var previews: some View {
            VStack(spacing: DesignSystem.Spacing.lg) {
                SearchBar(
                    text: $searchText,
                    placeholder: "Search items...",
                    onClear: {
                        print("Search tapped")
                    }
                )
                #if os(iOS)
                    TextInputField(
                        title: "Item Title",
                        placeholder: "Enter item title",
                        text: $inputText,
                        isRequired: true,
                        errorMessage: "Title is required"
                    )
                #endif
                SegmentedControl(
                    options: ["Option 1", "Option 2", "Option 3"],
                    selection: $selectedOption
                ) { option in
                    option
                }

                ToggleSwitch(
                    title: "Enable Notifications",
                    subtitle: "Receive updates about new items",
                    isOn: $isToggled
                )

                SliderInput(
                    title: "Font Size",
                    subtitle: "Adjust the text size for better readability",
                    value: $sliderValue,
                    range: 12...24,
                    step: 1.0
                ) { value in
                    "\(Int(value))pt"
                }
            }
            .padding()
            .background(DesignSystem.Colors.background)
        }
    }
#endif
