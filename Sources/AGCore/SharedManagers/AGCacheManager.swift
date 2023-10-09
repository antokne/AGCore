//
//  AGCacheManager.swift
//  RaceWeight
//
//  Created by Antony Gardiner on 19/12/22.
//
import Foundation
import OSLog
#if os(iOS)
import UIKit
#endif

public class AGCacheManager {
	
	public static let shared: AGCacheManager = AGCacheManager()
	
	private let log = Logger(subsystem: "com.antokne.agcore", category: "AGCacheManager")

	public func setImage(name: String, image: AGImage) {

		let png = image.pngData()
		
		if let fileUrl = fileUrl(filename: name) {
			do {
				try png?.write(to: fileUrl)
			}
			catch {
				log.error("Failed to write cache image \(error)")
			}
		}
	}
	
	public func getImage(name: String) -> AGImage? {
		
		if let fileUrl = fileUrl(filename: name) {
			if FileManager.default.fileExists(atPath: fileUrl.path(percentEncoded: false)) {
				do {
					let data = try Data(contentsOf: fileUrl)
					let image = AGImage(data: data, scale: AGImage.screenScale())
					return image
				}
				catch {
					log.error("Failed to read cached image \(error)")
				}
			}
		}
		return nil
	}
	
	public func resetImageCache() {
		if let path = mapImageCacheURL?.path(percentEncoded: false) {
			try? FileManager.default.removeItem(atPath: path)
		}
	}
	
	private func fileUrl(filename: String) -> URL? {
		var fileUrl = mapImageCacheURL?.appending(component: filename)
		fileUrl = fileUrl?.appendingPathExtension("png")
		return fileUrl
	}
	
	private var mapImageCacheURL: URL? {
		do {
			let cacheDirectory = try FileManager.default.url(for: .cachesDirectory,
															 in: .allDomainsMask,
															 appropriateFor: nil,
															 create: false)
			
			let mapImageDirectory = cacheDirectory.appending(component: "mapImages")
			AGCacheManager.createFolderIfRequired(url: mapImageDirectory)
			return mapImageDirectory
		}
		catch {
			print("mapImageCacheURL is bad \(error)")
		}
		return nil
	}
	
	private static func createFolderIfRequired(url: URL) {
		var isDirectory: ObjCBool = false
		
		do {
			if !FileManager.default.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDirectory) {
				try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
			}
		} catch {
			print("createFolderIfRequired fails \(error)")
		}
	}
}
