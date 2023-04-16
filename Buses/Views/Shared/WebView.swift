//
//  WebView.swift
//  Buses
//
//  Created by 堅書 on 16/4/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.layer.opacity = 0.0
        webView.load(URLRequest(url: url))
        return webView
    }

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Blank function to conform to protocol
    }

    class WebViewCoordinator: NSObject, WKNavigationDelegate {
        let cleanupJS = """
    // Disable selection
    var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}'
    var head = document.head || document.getElementsByTagName('head')[0]
    var style = document.createElement('style')
    style.type = 'text/css'
    style.appendChild(document.createTextNode(css))
    head.appendChild(style)

    // Remove extra elements
    document.querySelectorAll('.headerNavigation').forEach(x => { x.remove() })
    document.querySelectorAll('.sg-gov-header').forEach(x => { x.remove() })
    document.querySelectorAll('.sec-navbar').forEach(x => { x.remove() })
    document.getElementById('appPrompter').remove()
    document.querySelectorAll('.needsclick').forEach(x => { x.remove() })
    document.querySelectorAll('footer').forEach(x => { x.remove() })
    """

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(self.cleanupJS)
            webView.layer.opacity = 1.0
        }
    }
}
