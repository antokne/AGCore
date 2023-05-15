//
//  NSLabel.swift
//  
//
//  Created by Antony Gardiner on 15/05/23.
//

#if os(macOS)

import Foundation
import Cocoa

public class NSLabel: NSTextField {
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		configure()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		configure()
	}
	
	func configure() {
		self.isBezeled = false
		self.drawsBackground = false
		self.isEditable = false
		self.isSelectable = false
	}
}

#endif
