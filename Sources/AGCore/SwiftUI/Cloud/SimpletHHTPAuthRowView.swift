//
//  SimpletHHTPAuthRowView.swift
//  
//
//  Created by Antony Gardiner on 23/06/23.
//

import SwiftUI

public struct SimpletHHTPAuthRowView: View {
	@ObservedObject var viewModel: SimpleHTTPLoginViewModel
	
	public init(viewModel: SimpleHTTPLoginViewModel) {
		self.viewModel = viewModel
	}
	
	public var body: some View {
		Label {
			Text(viewModel.siteName)
			Spacer()
			if viewModel.isAuthenticated {
				Image(systemName: "checkmark.icloud")
			}
		} icon: {
			if let image = viewModel.siteImageName {
				Image(image)
					.renderingMode(.template)
					.resizable()
					.frame(width: 25, height: 25)
					.tint(.accentColor)
			}
		}
	}
}

struct SimpletHHTPAuthRowView_Previews: PreviewProvider {
	static var viewModel = SimpleHTTPLoginViewModel(siteName: "MyBikeTrafffic",
													service: SimpleHTTPService.myBikeTrafficService)

	static var previews: some View {
		SimpletHHTPAuthRowView(viewModel: viewModel)
	}
}
