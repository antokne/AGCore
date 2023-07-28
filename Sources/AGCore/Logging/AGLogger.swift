//
//  AGLogger.swift
//  
//
//  Created by Antony Gardiner on 20/06/23.
//

import Foundation
import OSLog
import MapKit
import UniformTypeIdentifiers

public enum AGLoggerError: Error {
	case failedToCreateFile
}

extension NSNotification.Name {
	public static let AGLoggerGenerateLog: NSNotification.Name = NSNotification.Name(rawValue: "AGLoggeGenerateLogNotificationName")
}

public struct AGLogFile: Hashable {
	public private(set) var logFileURL: URL
	
	public init(logFileURL: URL) {
		self.logFileURL = logFileURL
	}
	
	func resourceValues(forKeys keys: Set<URLResourceKey>) throws -> URLResourceValues {
		try logFileURL.resourceValues(forKeys: keys)
	}
}

public class AGLogger {
	
	private var name: String
	private var subSystemPrefex: String
	private var positionSince: TimeInterval
	
	let dateFormatter = DateFormatter()
	
	private var log = Logger(subsystem: "com.antokne.agcore", category: "AGLogger")

	
	public init(name: String, subSystemPrefix: String, duration: TimeInterval) {
		self.name = name
		self.subSystemPrefex = subSystemPrefix
		self.positionSince = duration
		dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
	}
	
	public func registerForNotifictions() {
		NotificationCenter.default.addObserver(forName: NSNotification.Name.AGLoggerGenerateLog,
											   object: nil,
											   queue: nil) { [weak self] notification in
			self?.notificationReceived()
		}
	}
	
	public func notificationReceived() {
		log.info("notificationReceived - generating logs.")
		Task {
			try? await generateLogFile()
		}
	}
	
	public func generateLogFile() async throws -> URL {
		
		var postion = positionSince
		let newestLogFile = allLogFiles.max { first, second in first < second }
		if let newestLogFile,  let newPositionDate = try newestLogFile.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate {
			print("newest position date = \(newPositionDate)")
			postion = -newPositionDate.timeIntervalSinceNow - 1
			print("position = \(postion)")
		}
		
		log.info("Generating logs from \(postion)")
		print("getting log enteries for position = \(postion)")
		let entries = try getLogEntries(positionSince: postion)
		let url = generateLogFileURL()
		try writeToFile(entries: entries, to: url)
		log.info("Generating logs completed")
		return url
	}
	
	func getLogEntries(positionSince: TimeInterval) throws -> [OSLogEntryLog] {
		let logStore = try OSLogStore(scope: .currentProcessIdentifier)
		let dateFrom = Date().addingTimeInterval(-positionSince)
		print("Generating logs from date \(dateFrom)")
		let position = logStore.position(date: dateFrom)
		let allEntries = try logStore.getEntries(at: position)
		let osLogEntryLogObjects = allEntries.compactMap { $0 as? OSLogEntryLog }
				
		return osLogEntryLogObjects.filter { $0.subsystem.hasPrefix(subSystemPrefex) }
	}
	
	func writeToFile(entries: [OSLogEntryLog], to url: URL) throws  {
		
		if FileManager.default.createFile(atPath: url.path(percentEncoded: false), contents: nil) == false {
			throw AGLoggerError.failedToCreateFile
		}
		
		let handle = try FileHandle(forWritingTo: url)
		
		for entry in entries {
			
			let logLine = generateLogMessage(entry: entry) + "\n"
			guard let data = logLine.data(using: .utf8) else {
				continue
			}
			
			try handle.write(contentsOf: data)
		}
		try handle.close()
	}
	
	var logFileFolder: URL {
		URL.temporaryDirectory
	}
	
	func generateLogFileURL() -> URL {
		logFileFolder.appendingPathComponent(generateFileName(), conformingTo: .log)
	}
	
	func generateFileName() -> String {
		String(format: "%@-%@.log", dateFormatter.string(from: Date()), name)
	}
	
	func generateLogMessage(entry: OSLogEntryLog) -> String {
		"\(dateFormatter.string(from: entry.date)) [\(entry.level.name)] \(entry.category): \(entry.composedMessage)"
	}
	
	public var allLogFiles: Set<AGLogFile>  {
		
		var logFiles: Set<AGLogFile> = []
		do {
			let files = try FileManager.default.contentsOfDirectory(at: logFileFolder, includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey])
			for file in files {
				if file.pathExtension == "log" && file.lastPathComponent.contains(name) {
					// have a log file
					logFiles.insert(AGLogFile(logFileURL: file))
				}
			}
		}
		catch {
			// we're doomed.
			log.info("allLogFiles - Failed to generate any logs \(error).")
		}
			
		return logFiles
	}
	
	public func delete(logs: Set<URL>) {
		for log in logs {
			try? FileManager.default.removeItem(at: log)
		}
	}
}


public extension OSLogEntryLog.Level {
	var name: String {
		switch self {
		case .undefined:
			return ""
		case .debug:
			return "debug"
		case .info:
			return "info"
		case .notice:
			return "notice"
		case .error:
			return "error"
		case .fault:
			return "fault"
		@unknown default:
			return ""
		}
	}
}

extension AGLogFile: Comparable {
	
	public static func < (lhs: AGLogFile, rhs: AGLogFile) -> Bool {
		(try? lhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast < (try? rhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
	}

}

