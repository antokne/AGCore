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

extension AGImage {
	public func pngData() -> Data? {
		tiffRepresentation?.bitmap?.png
	}
	
	public static func screenScale() -> CGFloat {
		NSScreen.main?.backingScaleFactor ?? 1.0
	}
	
	public convenience init?(data: Data, scale: CGFloat) {
		self.init(data: data)
	}
}

extension NSBitmapImageRep {
	var png: Data? { representation(using: .png, properties: [:]) }
}

extension Data {
	var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}


#endif
#if os(iOS)
import UIKit
public typealias AGColor = UIColor
public typealias AGImage = UIImage

extension AGImage {
	
	public convenience init?(systemSymbolName name: String, accessibilityDescription description: String?) {
		self.init(systemName: name)
	}
	
	public static func screenScale() -> Double {
		UIScreen.main.scale
	}
	
}
#endif



