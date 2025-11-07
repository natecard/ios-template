//
//  ToastManager.swift
//  ios-template
//
//  Manages and displays toast notifications throughout the app.
//

import SwiftUI

// MARK: - Toast Manager
@Observable
class ToastManager {
    private(set) var isShowing = false
    private(set) var title = ""
    private(set) var message = ""
    private(set) var type: ToastNotification.ToastType = .info

    @MainActor
    func showToast(
        title: String,
        message: String,
        type: ToastNotification.ToastType,
        duration: Double = 3.0
    ) {
        self.title = title
        self.message = message
        self.type = type

        withAnimation {
            isShowing = true
        }

        // Auto-dismiss after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.dismiss()
        }
    }

    @MainActor func showSuccess(title: String, message: String, duration: Double = 3.0) {
        showToast(title: title, message: message, type: .success, duration: duration)
    }

    @MainActor func showError(title: String, message: String, duration: Double = 5.0) {
        showToast(title: title, message: message, type: .error, duration: duration)
    }

    @MainActor func showWarning(title: String, message: String, duration: Double = 4.0) {
        showToast(title: title, message: message, type: .warning, duration: duration)
    }

    @MainActor func showInfo(title: String, message: String, duration: Double = 3.0) {
        showToast(title: title, message: message, type: .info, duration: duration)
    }

    func dismiss() {
        withAnimation {
            isShowing = false
        }
    }
}

// MARK: - Toast Manager View Modifier
struct ToastManagerModifier: ViewModifier {
    @State private var toastManager = ToastManager()

    func body(content: Content) -> some View {
        content
            .environment(toastManager)
            .overlay(alignment: .bottom) {
                if toastManager.isShowing {
                    ToastNotification(
                        title: toastManager.title,
                        message: toastManager.message,
                        type: toastManager.type
                    ) {
                        toastManager.dismiss()
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
                    .animation(DesignSystem.Animation.normal, value: toastManager.isShowing)
                }
            }
    }
}

// MARK: - View Extension
extension View {
    func withToastManager() -> some View {
        modifier(ToastManagerModifier())
    }
}

// MARK: - Preview
#if DEBUG
    #Preview {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Button("Show Success") {
                // This would be used from environment in real implementation
            }

            Button("Show Error") {
                // This would be used from environment in real implementation
            }

            Button("Show Warning") {
                // This would be used from environment in real implementation
            }

            Button("Show Info") {
                // This would be used from environment in real implementation
            }
        }
        .withToastManager()
        .padding()
        .background(DesignSystem.Colors.background)
    }
#endif
