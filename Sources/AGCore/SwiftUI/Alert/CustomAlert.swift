//
//  File.swift
//  
//
//  Created by Ant Gardiner on 11/07/23.
//

import SwiftUI

public struct CustomAlertButton: View {
	
	// MARK: - Value
	// MARK: Public
	let title: LocalizedStringKey
	let image: String?
	var action: (() -> Void)? = nil
	
	public init(title: LocalizedStringKey, image: String? = nil, action: ( () -> Void)? = nil) {
		self.title = title
		self.image = image
		self.action = action
	}
	
	// MARK: - View
	// MARK: Public
	public var body: some View {
		Button {
			action?()
		} label: {
			if let image {
				Image(systemName: image)
			}
			Text(title)
		}
	}
}

public struct CustomAlert: View {
	
	// MARK: - Value
	// MARK: Public
	let title: String
	let message: String
	let dismissButton: CustomAlertButton?
	let primaryButton: CustomAlertButton?
	let secondaryButton: CustomAlertButton?
	
	// MARK: Private
	@State private var opacity: CGFloat           = 0
	@State private var backgroundOpacity: CGFloat = 0
	@State private var scale: CGFloat             = 0.001
	
	@Environment(\.dismiss) private var dismiss
	
	
	// MARK: - View
	// MARK: Public
	public var body: some View {
		alertView
	}
	
	// MARK: Private
	private var alertView: some View {
		VStack(spacing: 20) {
			titleView
			messageView
			buttonsView
			Spacer()
		}
		.padding(24)
		.background(.white)
	}
	
	@ViewBuilder
	private var titleView: some View {
		if !title.isEmpty {
			Text(title)
				.font(.title)
				.foregroundColor(.black)
				.lineSpacing(24 - UIFont.systemFont(ofSize: 18, weight: .bold).lineHeight)
				.multilineTextAlignment(.leading)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
	
	@ViewBuilder
	private var messageView: some View {
		if !message.isEmpty {
			Text(message)
				.foregroundColor(title.isEmpty ? .black : .gray)
				.lineSpacing(24 - UIFont.systemFont(ofSize: title.isEmpty ? 18 : 16).lineHeight)
				.multilineTextAlignment(.leading)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
	
	private var buttonsView: some View {
		HStack(spacing: 12) {
			
			VStack {
				HStack {
					if dismissButton != nil {
						dismissButtonView
					}
					if primaryButton != nil {
						if dismissButton != nil {
							Spacer()
						}
						primaryButtonView
							.buttonStyle(.borderedProminent)
					}
				}
				Spacer()
				if secondaryButton != nil {
					secondaryButtonView
						.font(.caption2)
				}
			}
		}
		
		.padding(.top, 23)
	}
	
	@ViewBuilder
	private var primaryButtonView: some View {
		if let button = primaryButton {
			CustomAlertButton(title: button.title) {
				animate(isShown: false) {
					dismiss()
				}
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
					button.action?()
				}
			}
		}
	}
	
	@ViewBuilder
	private var secondaryButtonView: some View {
		if let button = secondaryButton {
			CustomAlertButton(title: button.title) {
				animate(isShown: false) {
					dismiss()
				}
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
					button.action?()
				}
			}
		}
	}
	
	@ViewBuilder
	private var dismissButtonView: some View {
		if let button = dismissButton {
			CustomAlertButton(title: button.title) {
				animate(isShown: false) {
					dismiss()
				}
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
					button.action?()
				}
			}
		}
	}
	
	
	// MARK: - Function
	// MARK: Private
	private func animate(isShown: Bool, completion: (() -> Void)? = nil) {
		switch isShown {
		case true:
			opacity = 1
			
			withAnimation(.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0).delay(0.5)) {
				backgroundOpacity = 1
				scale             = 1
			}
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				completion?()
			}
			
		case false:
			withAnimation(.easeOut(duration: 0.2)) {
				backgroundOpacity = 0
				opacity           = 0
			}
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				completion?()
			}
		}
	}
}

struct CustomAlert_Previews: PreviewProvider {
	
	static var previews: some View {
		let dismissButton   = CustomAlertButton(title: "Cancel")
		let primaryButton   = CustomAlertButton(title: "Save")
		let secondaryButton = CustomAlertButton(title: "Discard")
		
		let title = "This is your life. Do what you want and do it often."
		let message = """
					If you don't like something, change it.
					If you don't like your job, quit.
					If you don't have enough time, stop watching TV.
					"""
		
		return VStack {
			CustomAlert(title: title,
						message: message,
						dismissButton: nil,
						primaryButton: primaryButton,
						secondaryButton: nil)
			CustomAlert(title: title,
						message: message,
						dismissButton: dismissButton,
						primaryButton: nil,
						secondaryButton: nil)
			
			CustomAlert(title: title,
						message: message,
						dismissButton: dismissButton,
						primaryButton: primaryButton,
						secondaryButton: secondaryButton)
		}
		.previewDevice("iPhone 13 Pro Max")
		.preferredColorScheme(.dark)
	}
}
