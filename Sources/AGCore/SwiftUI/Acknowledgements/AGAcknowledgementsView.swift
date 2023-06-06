//
//  SwiftUIView.swift
//  
//
//  Created by Antony Gardiner on 26/05/23.
//

import SwiftUI

public struct AGAcknowledgementsView: View {
	
	var packages: [AGPackage]
	var applicationName: String
	
	public init(packages: [AGPackage], applicatioName: String) {
		self.packages = packages
		self.applicationName = applicatioName
	}
	
	public var body: some View {
		NavigationStack {
			List {
				VStack {
					Text("The following open source software is used in \(applicationName).")
						.padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 10))
				}
				ForEach(packages) { package in
					if let url = package.url {
						Link(package.title, destination: url)
							.bold()
							.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
					}
				}
			}
		}
		.navigationTitle("Acknowledgements")
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
	}
}

struct AGAcknowledgementsView_Previews: PreviewProvider {
	static var previews: some View {
		AGAcknowledgementsView(packages: [.alamofire], applicatioName: "Test")
	}
}
