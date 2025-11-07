//
//  NavigationBarModifier.swift
//  ios-template
//
//  Modifier to customize navigation bar appearance.
//

import SwiftUI

#if os(iOS)
    struct NavigationBarModifier: ViewModifier {
        init(fontSize: Double, _ weight: UIFont.Weight?) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.largeTitleTextAttributes = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: weight ?? .semibold)
            ]
            navBarAppearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: weight ?? .semibold)
            ]
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }

        func body(content: Content) -> some View {
            content
        }
    }

    extension View {
        func navigationBarModifier(fontSize: Double, _ weight: UIFont.Weight?) -> some View {
            modifier(NavigationBarModifier(fontSize: fontSize, weight ?? .semibold))
        }
    }
#endif
