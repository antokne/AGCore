//
//  FileManager+Extensions.swift
//  
//
//  Created by Antony Gardiner on 16/02/23.
//

import Foundation

public struct FileManagerHelpers {
	
	
	
	public func fileSize(url: URL) -> Int? {
		
		if #available(macOS 13.0, iOS 16.0, *) {
			if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false)) {
				let size = attributes[.size]
				return size as? Int
			}
		}
		
		return nil
	}
}

extension FileManager {
	
	public static var helpers: FileManagerHelpers = FileManagerHelpers()
	
}
