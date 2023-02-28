//
//  AGAliases.swift
//  RaceWeight
//
//  Created by Antony Gardiner on 10/02/23.
//

import Foundation

#if os(macOS)
import Cocoa
public typealias AGColor = NSColor
public typealias AGImage = NSImage
#endif
#if os(iOS)
import UIKit
public typealias AGColor = UIColor
public typealias AGImage = UIImage

extension AGImage {
	
	public convenience init?(systemSymbolName name: String, accessibilityDescription description: String?) {
		self.init(systemName: name)
	}
	
}
#endif



