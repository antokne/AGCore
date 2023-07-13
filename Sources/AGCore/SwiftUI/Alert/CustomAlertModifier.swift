//
//  File.swift
//  
//
//  Created by Ant Gardiner on 11/07/23.
//

import SwiftUI

public struct CustomAlertModifier {
	
	// MARK: - Value
	// MARK: Private
	@Binding private var isPresented: Bool
	
	// MARK: Private
	private let title: String
	private let message: String
	private let dismissButton: CustomAlertButton?
	private let primaryButton: CustomAlertButton?
	private let secondaryButton: CustomAlertButton?
}


@available(iOS 16.4, *)
extension CustomAlertModifier: ViewModifier {
	
	public func body(content: Content) -> some View {
		content
			.sheet(isPresented: $isPresented) {
				CustomAlert(title: title, message: message, dismissButton: dismissButton, primaryButton: primaryButton, secondaryButton: secondaryButton)
					.presentationDetents([.medium])
			}
	}
}

extension CustomAlertModifier {
	
	public init(title: String = "",
		 message: String = "",
		 dismissButton: CustomAlertButton? = nil,
		 primaryButton: CustomAlertButton? = nil,
		 secondaryButton: CustomAlertButton? = nil,
		 isPresented: Binding<Bool>) {
		self.title           = title
		self.message         = message
		self.dismissButton = dismissButton
		self.primaryButton   = primaryButton
		self.secondaryButton = secondaryButton
		
		_isPresented = isPresented
	}
}

extension View {
	
	public func alert(title: String = "",
			   message: String = "",
			   dismissButton: CustomAlertButton = CustomAlertButton(title: "ok"),
			   primaryButton: CustomAlertButton? = nil,
			   secondaryButton: CustomAlertButton? = nil,
			   isPresented: Binding<Bool>) -> some View {
		let title   = NSLocalizedString(title, comment: "")
		
		let message = NSLocalizedString(message, comment: "")
		
		return modifier(CustomAlertModifier(title: title,
											message: message,
											dismissButton: dismissButton,
											primaryButton: primaryButton,
											secondaryButton: secondaryButton,
											isPresented: isPresented))
	}
}


struct DemoView: View {
	
	// MARK: - Value
	// MARK: Private
	@State private var isAlertPresented = false
	
	
	// MARK: - View
	// MARK: Public
	var body: some View {
		VStack {
			Spacer()
			Text("Some text to hide")
			Spacer()
			Text("More Text")
			Spacer()
			Button {
				isAlertPresented = true
				
			} label: {
				Text("Alert test")
			}
			.alert(title: "Finish recording Activity?", message: "Would you like to finish this activity and save it, or continue recording, or discard it?",
				   dismissButton: CustomAlertButton(title: "Continue", action: { }),
				   primaryButton: CustomAlertButton(title: "Save", action: { }),
				   secondaryButton: CustomAlertButton(title: "Discard", action: {  }),
				   isPresented: $isAlertPresented)
			Spacer()
		}
	}
}

struct DemoView_Previews: PreviewProvider {
	
	static var previews: some View {
		VStack {
			Rectangle()
				.foregroundColor(.red)
			Rectangle()
				.foregroundColor(.gray)
			Rectangle()
				.foregroundColor(.green)
			Spacer()
			DemoView()
				.previewDevice("iPhone 11 Pro")
		}
	}
}
