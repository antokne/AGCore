//
//  AGWebView.swift
//  
//
//  Created by Ant Gardiner on 17/07/23.
//

import SwiftUI
import WebKit

#if os(macOS)
import AppKit
public typealias AGViewRepresentable = NSViewRepresentable
#endif

#if os(iOS)
public typealias AGViewRepresentable = UIViewRepresentable
#endif

public struct AGWebView: AGViewRepresentable {

	let url: URL
	var webConfig: WKWebViewConfiguration?
	
	public init(url: URL, webConfig: WKWebViewConfiguration? = nil) {
		self.url = url
		self.webConfig = webConfig
	}

#if os(iOS)
	public func makeUIView(context: Context) -> WKWebView  {
		var wkwebView = WKWebView()
		if let webConfig {
			wkwebView = WKWebView(frame: .zero, configuration: webConfig)
		}
		let request = URLRequest(url: url)
		wkwebView.load(request)
		return wkwebView
	}
	
	public func updateUIView(_ uiView: WKWebView, context: Context) {
	}
#endif
	
#if os(macOS)

	public func makeNSView(context: Self.Context) -> WKWebView {
		var wkwebView = WKWebView()
		if let webConfig {
			wkwebView = WKWebView(frame: .zero, configuration: webConfig)
		}
		let request = URLRequest(url: url)
		wkwebView.load(request)
		return wkwebView
	}
	
	public func updateNSView(_ nsView: WKWebView, context: Self.Context) {
		
	}
#endif

	
}




struct AGWebView_Previews: PreviewProvider {
	static var previews: some View {
		AGWebView(url: URL(string: "https://homeworldwiki.com")!)
	}
}
