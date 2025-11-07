//
//  WebViewComponents.swift
//  ios-template
//
//  SwiftUI WebView component for displaying HTML content.
//

import SwiftUI
import WebKit

#if os(iOS)
    struct HTMLWebView: UIViewRepresentable {
        let url: URL

        func makeUIView(context: Context) -> WKWebView {
            let configuration = WKWebViewConfiguration()
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.allowsBackForwardNavigationGestures = true
            return webView
        }

        func updateUIView(_ webView: WKWebView, context: Context) {
            if webView.url != url {
                webView.load(URLRequest(url: url))
            }
        }
    }

#endif
