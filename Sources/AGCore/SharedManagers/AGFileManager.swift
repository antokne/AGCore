//
//  AGFileManager.swift
//  RaceWeight
//
//  Created by Antony Gardiner on 14/12/22.
//

import Foundation

public class AGFileManager {
	
	public static let shared: AGFileManager = AGFileManager()
	
	public static var documentsURL = URL.documentsDirectory

	public static func documentsSubDirectory(path: String) -> URL? {
		let url = AGFileManager.documentsURL.appending(path: "activities")
		let exists = FileManager.default.fileExists(atPath: url.path())
		if !exists {
			do {
				try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
			}
			catch {
				return nil
			}
		}
		return url
	}
}
