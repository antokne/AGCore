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
	
	public static var mainBundleId: String? {
		Bundle.main.bundleIdentifier
	}
	
	public var version: String {
		return infoDictionary?["CFBundleShortVersionString"] as! String
	}
	
	public var buildNumber: String {
		return infoDictionary?["CFBundleVersion"] as! String
	}
}
