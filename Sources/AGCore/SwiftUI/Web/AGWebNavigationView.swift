//
//  AGWebNavigationView.swift
//  
//
//  Created by Ant Gardiner on 16/08/23.
//

import Foundation
import SwiftUI
import WebKit

public struct AGWebNavigationView: View {
	
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.openURL) var openURL
	
	var title: String
	var url: URL
	var webConfig: WKWebViewConfiguration?
	
#if os(iOS)
	let leading = ToolbarItemPlacement.navigationBarLeading
	let trailing = ToolbarItemPlacement.navigationBarTrailing
#elseif os(macOS)
	let leading = ToolbarItemPlacement.automatic
	let trailing = ToolbarItemPlacement.automatic
#endif
	
	public init(title: String, url: URL, webConfig: WKWebViewConfiguration? = nil) {
		self.title = title
		self.url = url
		self.webConfig = webConfig
	}
	
	public var body: some View {
		NavigationStack {
			AGWebView(url: url, webConfig: webConfig)
				.navigationTitle(title)
#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
#endif
				.toolbar {
					ToolbarItem(placement: leading) {
						Button(action: {
							openURL(url)
						}) {
							Image(systemName: "safari")
						}
					}
					ToolbarItem(placement: trailing) {
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}) {
							Text("Done")
						}
					}
			}
		}
	}
}


struct AGWebNavigationView_Previews: PreviewProvider {
	static var previews: some View {
		AGWebNavigationView(title: "Bob", url: URL(string: "https://homeworldwiki.com")!)
	}
}
