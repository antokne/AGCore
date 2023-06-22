//
//  AGLogger.swift
//  
//
//  Created by Antony Gardiner on 20/06/23.
//

import Foundation
import OSLog

public enum AGLoggerError: Error {
	case failedToCreateFile
}

public class AGLogger {
	
	private var name: String
	private var subSystemPrefex: String
	private var posistionSince: TimeInterval
	
	let dateFormatter = DateFormatter()

	public init(name: String, subSystemPrefix: String, duration: TimeInterval) {
		self.name = name
		self.subSystemPrefex = subSystemPrefix
		self.posistionSince = duration
		dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
	}
	
	public func generateLogFile() async throws -> URL {
		let entries = try getLogEntries()
		let url = generateLogFileURL()
		try writeToFile(entries: entries, to: url)
		return url
	}
	
	func getLogEntries() throws -> [OSLogEntryLog] {
		let logStore = try OSLogStore(scope: .currentProcessIdentifier)
		let dateFrom = Date().addingTimeInterval(-posistionSince)
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
	
	func generateLogFileURL() -> URL {
		URL.temporaryDirectory.appendingPathComponent(generateFileName(), conformingTo: .log)
	}
	
	func generateFileName() -> String {
		String(format: "%@-%@.log", dateFormatter.string(from: Date()), name)
	}
	
	func generateLogMessage(entry: OSLogEntryLog) -> String {
		"\(dateFormatter.string(from: entry.date)) [\(entry.level.name)] \(entry.category): \(entry.composedMessage)"
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
