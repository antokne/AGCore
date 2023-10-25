//
//  Bool+VersionExtensions.swift
//
//
//  Created by Ant Gardiner on 20/10/23.
//

import Foundation

public extension Bool {
	static var iOS17: Bool {
		guard #available(iOS 17, *) else {
			// It's iOS 17 so return true.
			return true
		}
		return false
	}
}
