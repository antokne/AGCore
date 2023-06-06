//
//  GenericTopBar.swift
//  Gruppo
//
//  Created by Antony Gardiner on 10/03/23.
//

import SwiftUI

public struct GenericBarActionView: View {
	var title: String
	var action: () -> Void
	
	public var body: some View {
		Button(title) {
			action()
		}
		.padding()
	}
}

public struct GenericTopBarView<Content: View>: View {
	var title: String
	private var leftBarAction: Content
	private var rightBarAction: Content?
	
	public init(title: String, _ leftBarAction: @escaping () -> Content, rightBarAction: (() -> Content)? = nil) {
		self.title = title
		self.leftBarAction = leftBarAction()
		self.rightBarAction = rightBarAction?()
	}
	
	public var body: some View {
		HStack {
			leftBarAction
			Spacer()
			Text(title)
				.font(Font.title2)
			Spacer()
			if let rightBarAction {
				rightBarAction
			}
		}
		.overlay(Divider(), alignment: .bottom)
	}
}


struct GenericTopBar_Previews: PreviewProvider {
	static var previews: some View {
		GenericTopBarView(title: "Title") {
			Text("hi")
		} rightBarAction: {
			Text("hi")
		}
	}
}
