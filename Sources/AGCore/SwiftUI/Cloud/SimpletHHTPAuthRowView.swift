//
//  SimpletHHTPAuthRowView.swift
//  
//
//  Created by Antony Gardiner on 23/06/23.
//

import SwiftUI

public struct SimpletHHTPAuthRowView: View {
	@ObservedObject var viewModel: SimpleHTTPLoginViewModel
	
	@State private var autoUpload = false

	var autoUploadFeatureEnabled: Bool

	public init(viewModel: SimpleHTTPLoginViewModel, autoUploadFeatureEnabled: Bool = true) {
		self.viewModel = viewModel
		self.autoUploadFeatureEnabled = autoUploadFeatureEnabled
	}
	
	public var body: some View {
		Label {
			VStack {
				HStack {
					Text(viewModel.siteName)
					Spacer()
					if viewModel.isAuthenticated {
						Image(systemName: "checkmark.icloud")
					}
				}
				if viewModel.isAuthenticated, autoUploadFeatureEnabled {
					Toggle(isOn: $viewModel.automaticUpload, label: { Text("Auto upload") })
				}
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
		List {
			SimpletHHTPAuthRowView(viewModel: viewModel, autoUploadFeatureEnabled: true)
		}
	}
}
