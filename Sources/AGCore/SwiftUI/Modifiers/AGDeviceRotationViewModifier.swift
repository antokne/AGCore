//
//  AGDeviceRotationViewModifier.swift
//  
//
//  Created by Antony Gardiner on 19/03/23.
//

import SwiftUI

public struct AGDeviceRotationViewModifier: ViewModifier {
	let action: (UIDeviceOrientation) -> Void
	
	public func body(content: Content) -> some View {
		content
			.onAppear()
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				action(UIDevice.current.orientation)
			}
	}
}

extension View {
	public func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
		self.modifier(AGDeviceRotationViewModifier(action: action))
	}
}
