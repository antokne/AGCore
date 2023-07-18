//
//  AGFeatureView.swift
//  
//
//  Created by Ant Gardiner on 17/07/23.
//

import SwiftUI

public struct AGFeatureView: View {
	
	@State var feature: AGFeatureProtocol
	@State var enabled: Bool
	var action: (Bool) -> Void
	
	@State var enableInProgress = false
	
	public init(feature: AGFeatureProtocol, action: @escaping (_ enabled: Bool) -> Void) {
		_feature = State(initialValue: feature)
		_enabled = State(initialValue: feature.enabled)
		self.action = action
	}
	
	public var body: some View {
		VStack(alignment: .leading) {
			HStack {
				VStack {
					HStack {
						Text(feature.iconName)
							.font(.system(size: 40))
							.background(.ultraThickMaterial)
							.cornerRadius(5)
						Text(feature.name)
							.font(.title2)
					}
					Text(feature.description)
						.foregroundColor(.secondary)
				}
				Spacer()
				if enabled {
					Image(systemName: "checkmark")
				}
			}

			if enabled == false {
				if enableInProgress {
					ProgressView()
				}
				else {
					Button {
						enable()
					} label: {
						Image(systemName: "lock.open.fill")
						Text(feature.unlockTitle)
					}
					.buttonStyle(.borderedProminent)
				}
			}
//			else {
//				Button("disable") {
//					feature.enabled = false
//					enabled = false
//				}
//				.font(.caption2)
//				.foregroundColor(.secondary)
//			}
		}
	}
	
	func enable() {
		enableInProgress = true
		Task { @MainActor in
			enabled = try await feature.unlock()
			action(enabled)
			enableInProgress = false
		}
	}
}

struct AGFeatureView_Previews: PreviewProvider {
	static var previews: some View {
		List {
			AGFeatureView(feature: AGFeatureUserDefaults(iconName: "🚴",
														 name: "Bla feature",
														 description: "Do this or do that?",
					 									 rule: AGFeatureRuleLimitCount(value: 3))) { enabled in
				
			}
		}
	}
}
