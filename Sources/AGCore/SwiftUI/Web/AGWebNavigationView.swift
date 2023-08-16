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
	
	var title: String
	var url: URL
	var webConfig: WKWebViewConfiguration?
	
	public init(title: String, url: URL, webConfig: WKWebViewConfiguration? = nil) {
		self.title = title
		self.url = url
		self.webConfig = webConfig
	}
	
	public var body: some View {
		NavigationStack {
			AGWebView(url: url, webConfig: webConfig)
				.navigationTitle(title)
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigationBarLeading) {
						Button(action: {
							UIApplication.shared.open(url)
						}) {
							Image(systemName: "safari")
						}
					}
					ToolbarItem(placement: .navigationBarTrailing) {
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
