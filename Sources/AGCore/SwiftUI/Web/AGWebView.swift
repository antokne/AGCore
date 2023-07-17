//
//  AGWebView.swift
//  
//
//  Created by Ant Gardiner on 17/07/23.
//

import SwiftUI
import WebKit

public struct AGWebView: UIViewRepresentable {

	let url: URL
	
	public init(url: URL) {
		self.url = url
	}

	public func makeUIView(context: Context) -> WKWebView  {
		let wkwebView = WKWebView()
		let request = URLRequest(url: url)
		wkwebView.load(request)
		return wkwebView
	}
	
	public func updateUIView(_ uiView: WKWebView, context: Context) {
	}
}

struct AGWebView_Previews: PreviewProvider {
	static var previews: some View {
		AGWebView(url: URL(string: "https://homeworldwiki.com")!)
	}
}
