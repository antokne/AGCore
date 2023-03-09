//
//  File.swift
//  
//
//  Created by Antony Gardiner on 9/03/23.
//

import Foundation

extension Bundle {
	public var applicationName: String? {
		object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
		object(forInfoDictionaryKey: "CFBundleName") as? String
	}
}
