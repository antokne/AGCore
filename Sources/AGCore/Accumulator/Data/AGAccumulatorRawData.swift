//
//  AGAccumatorRawData.swift
//  
//
//  Created by Antony Gardiner on 30/05/23.
//

import Foundation
import os

public struct AGAccumulatorRawInstantData: Codable {
	var instant: [AGDataType: Double] = [: ]
	internal(set) public var paused: Bool = false
	mutating func add(value: AGDataTypeValue) {
		instant[value.type] = value.value
	}
	
	public func value(for type: AGDataType) -> Double? {
		instant[type]
	}
}

public struct AGAccumulatorRawArrayInstantData: Codable {
	var instant: [AGDataType: [Double]] = [: ]
	internal(set) public var paused: Bool = false
	mutating func add(value: AGDataTypeArrayValue) {
		instant[value.type] = value.values
	}
	
	public func values(for type: AGDataType) -> [Double]? {
		instant[type]
	}
}

// Outside of struct so it does not muck up the Codable stuff.
private var logger = Logger(subsystem: "com.antokne.core", category: "AGAccumulatorRawData")

/// A struct that contains all the data we are collecting whether paused or not.
/// This allows us to recontruct anything using this data.
/// Recorded at 1Hz as is the standard.
public struct AGAccumulatorRawData: Codable {
	
	public enum Status {
		case progress(Float)
		case completed(AGAccumulatorRawData)
	}
	
	/// All data added to raw data dict.
	private(set) public var data: [Int: AGAccumulatorRawInstantData] = [: ]
	
	private(set) public var arrayData: [Int: AGAccumulatorRawArrayInstantData] = [: ]
	
	private(set) public var maxSecond: Int = 0
	
	/// updated during save process.
	private(set) public var cachedSecond: Int = 0
	
	/// Added a vale for a data type for the second specified. Overwrites data if it exists.
	/// - Parameters:
	///   - value: the type value to set
	///   - second: the second since activity start
	///   - paused: falg indicating if currently paused.
	mutating func add(value: AGDataTypeValue, second: Int, paused: Bool = false) {
		if data[second] == nil {
			data[second] = AGAccumulatorRawInstantData()
		}
		data[second]?.add(value: value)
		data[second]?.paused = paused
		updateSecond(second: second)
	}
	
	/// Add an array value for this second
	/// - Parameters:
	///   - arrayValue: an array of data for this second
	///   - second: second into activiy this data represents
	mutating func add(arrayValue: AGDataTypeArrayValue, second: Int, paused: Bool = false) {
		if arrayData[second] == nil {
			arrayData[second] = AGAccumulatorRawArrayInstantData()
		}
		arrayData[second]?.add(value: arrayValue)
		arrayData[second]?.paused = paused
		updateSecond(second: second)
	}
	
	func paused(second: Int) -> Bool {
		data[second]?.paused ?? false
	}
	
	private mutating func updateSecond(second: Int) {
		self.maxSecond = max(self.maxSecond, second)
	}
	
	private mutating func updateCacheSecond(second: Int) {
		cachedSecond = second
	}
	
	public func value(for second: Int, type: AGDataType) -> Double? {
		data[second]?.value(for: type)
	}
	
	public func arrayValues(for second: Int, type: AGDataType) -> [Double]? {
		arrayData[second]?.values(for: type)
	}
	
	
	mutating func clear() {
		data = [:] // 💥
	}
	
	
	private static let activityInstantValueDataFileName = "activity-instant-value-data.txt"
	private static let activityArrayValuesDataFileName = "activity-array-values-data.txt"
	private static let secondDataSeparator = "-@-"
	
	/// write cache data.
	/// - Parameter folder: location to put cache files
	public mutating func cache(to folder: URL) throws {
		
		// instant value data
		var fileName = folder.appending(path: AGAccumulatorRawData.activityInstantValueDataFileName)
		try save(fileName: fileName, valueData: data)

		// Instant array data
		fileName = folder.appending(path: AGAccumulatorRawData.activityArrayValuesDataFileName)
		try save(fileName: fileName, valueData: arrayData)
		
		updateCacheSecond(second: maxSecond )
	}
	
	/// Removes the cache files located in folder
	/// - Parameter folder: location of the cache files to remove
	public func clearCache(in folder: URL) {
		
		var fileName = folder.appending(path: AGAccumulatorRawData.activityInstantValueDataFileName)
		try? FileManager.default.removeItem(at: fileName)
		
		fileName = folder.appending(path: AGAccumulatorRawData.activityArrayValuesDataFileName)
		try? FileManager.default.removeItem(at: fileName)
	}
	
	/// Save the raw value data cache files into file.
	/// Note that this remembers last second saved. so only saves the new delta data each time called
	/// - Parameters:
	///   - fileName: file name where to save the data
	///   - valueData: value array to encode and save.
	private mutating func save<T: Encodable>(fileName: URL, valueData: [Int: T]) throws {
		let encoder = JSONEncoder()

		logger.info("Saving cache data for \(fileName.lastPathComponent, privacy: .public)")
		
		if cachedSecond == 0 {
			logger.info("creating new file \(fileName)")
			FileManager.default.createFile(atPath: fileName.path(percentEncoded: false), contents: nil)
		}
		let fileHandle = try FileHandle(forWritingTo: fileName)
		try fileHandle.seekToEnd()
				
		// write data
		for second in cachedSecond...maxSecond {
			
			let instantValueData = valueData[second]
			
			if instantValueData == nil {
				continue
			}
			
			let data = try encoder.encode(instantValueData)
			let encodedString = "\(second)" + AGAccumulatorRawData.secondDataSeparator + (String(data: data, encoding: .utf8) ?? "") + "\n"
			
			if let theData = encodedString.data(using: .utf8) {
				fileHandle.write(theData)
			}
			
		}
		
		try fileHandle.close()
		let seconds = maxSecond - cachedSecond
		logger.info("Saving cache data completed. cached \(seconds, privacy: .public) seconds")
	}
	
	public static func load(from folder: URL, progress: @escaping (Double) -> Void) async throws -> AGAccumulatorRawData {
		
		var loaded = AGAccumulatorRawData()
						
		
		let valuesFileName = folder.appending(path: activityInstantValueDataFileName)
		let valuesFileSize = FileManager.helpers.fileSize(url: valuesFileName) ?? 0
		
		let arrayFileName = folder.appending(path: activityArrayValuesDataFileName)
		let arrayValuesFileSize = FileManager.helpers.fileSize(url: arrayFileName) ?? 0
		
		let totalFileSize = (arrayValuesFileSize + valuesFileSize)
		
		var progressFileSize = 0
		
		var accumulatedProgress: Double {
			Double(progressFileSize) / Double(totalFileSize)
		}
		
		loaded.data = try await loaded.load(fileName: valuesFileName, type: AGAccumulatorRawInstantData.self) { loadProgress in
			progressFileSize += loadProgress
			updateProgress(progress: accumulatedProgress, progressCompletion: progress)
		}
		
		loaded.arrayData = try await loaded.load(fileName: arrayFileName, type: AGAccumulatorRawArrayInstantData.self) { loadProgress in
			progressFileSize += loadProgress
			updateProgress(progress: accumulatedProgress, progressCompletion: progress)
		}
		
		return loaded
	}
	
	/// Update pogress on the main threas
	/// - Parameters:
	///   - progress: percent progress
	///   - progressCompletion: completion to call on main thread.
	static func updateProgress(progress: Double, progressCompletion: @escaping (Double) -> Void) {
		DispatchQueue.main.async {
			progressCompletion(progress)
		}
	}
		
	public mutating func load<T: Decodable>(fileName: URL, type: T.Type, progress: (Int) -> Void) async throws  -> [Int: T] {
		
		logger.info("Loading cache data for \(fileName.lastPathComponent, privacy: .public)")
		
		let decoder = JSONDecoder()
		
		var valueData: [Int: T] = [:]
				
		for try await line in fileName.lines {
			
			progress(line.count + 1)
			
			let parts = line.split(separator: AGAccumulatorRawData.secondDataSeparator)
			let second = Int(parts.first ?? "0") ?? 0
			let encodedString = parts.last ?? ""
			
			if encodedString == "null" {
				continue
			}
			
			guard let rawData = encodedString.data(using: .utf8) else {
				continue
			}
			
			let instantData = try decoder.decode(T.self, from: rawData)
			
			valueData[second] = instantData
			self.updateSecond(second: second)
		}
		logger.info("Loading cache data completed")
		
		return valueData
	}

}
