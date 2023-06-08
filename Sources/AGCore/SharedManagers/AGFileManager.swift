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
	
	/// Constructs a url  folder from documents folder and creates if required.
	/// - Parameters:
	///   - path: path to generate
	///   - create: create it?
	/// - Returns: URL if all good.
	public static func documentsSubDirectory(path: String, create: Bool = true) -> URL? {
		let url = AGFileManager.documentsURL.appending(path: path)
		let exists = FileManager.default.fileExists(atPath: url.path())
		if !exists && create {
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
