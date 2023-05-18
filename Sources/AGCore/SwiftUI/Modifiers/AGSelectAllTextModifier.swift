//
//  AGSelectAllTextModifier.swift
//  
//
//  Created by Antony Gardiner on 5/05/23.
//

import Foundation
import SwiftUI

#if os(iOS)
public struct SelectTextOnEditingModifier: ViewModifier {
	var currentValue: String
	public func body(content: Content) -> some View {
		content
			.onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
				if let textField = obj.object as? UITextField,
				   textField.text == currentValue {
					textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
				}
			}
	}
}

extension View {
	
	/// Select all the text in a TextField when starting to edit.
	/// This uses the current text value to compare that we are selecting the correct text field.
	public func selectAllTextOnEditing(currentValue: String) -> some View {
		modifier(SelectTextOnEditingModifier(currentValue: currentValue))
	}
}

#endif
