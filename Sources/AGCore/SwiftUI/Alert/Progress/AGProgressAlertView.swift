//
//  SwiftUIView.swift
//  
//
//  Created by Ant Gardiner on 18/08/23.
//

import SwiftUI

public struct AGProgressAlertView: View {
	
	var title: String
	var percent: Double
	var backgroudColor: Color
	
	public init(title: String, percent: Double, backgroundColor: Color = Color(white: 0.75)) {
		self.title = title
		self.percent = percent
		self.backgroudColor = backgroundColor
	}
	
	public var body: some View {
		VStack {
			Text(title)
				.font(.title)
				.minimumScaleFactor(0.5)
			ProgressView(value: percent)
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(backgroudColor)
		.cornerRadius(10)
	}
}

struct AGProgressAlertView_Previews: PreviewProvider {
	
	static var inprogress = true
	
	static var previews: some View {
		
		VStack(spacing: 10) {
			Spacer()
			Text("backgound text")
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding()
		.overlay {
			if inprogress {
				AGProgressAlertView(title: "Loading...", percent: 0.5)
			}
		}
		.padding()
	}
}
