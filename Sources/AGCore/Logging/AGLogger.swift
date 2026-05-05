//
//  AGLogger.swift
//
//
//  Created by Antony Gardiner on 20/06/23.
//

import Foundation
#if DEBUG
import os
#endif

public enum AGLoggerError: Error {
	case failedToCreateFile
}

extension NSNotification.Name {
	public static let AGLoggerGenerateLog: NSNotification.Name = NSNotification.Name(rawValue: "AGLoggerGenerateLogNotificationName")
}

public struct AGLogFile: Hashable, Sendable {
	public private(set) var logFileURL: URL

	public init(logFileURL: URL) {
		self.logFileURL = logFileURL
	}

	func resourceValues(forKeys keys: Set<URLResourceKey>) throws -> URLResourceValues {
		try logFileURL.resourceValues(forKeys: keys)
	}
}

extension AGLogFile: Comparable {
	public static func < (lhs: AGLogFile, rhs: AGLogFile) -> Bool {
		let lhsDate = (try? lhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
		let rhsDate = (try? rhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
		return lhsDate < rhsDate
	}
}

/// Drop-in replacement for `os.Logger`. Writes every message to the shared rolling log file
/// and, in DEBUG builds, also forwards to OSLog so messages appear in the Xcode console.
public struct AGLogger: Sendable {

	public let subsystem: String
	public let category: String

	#if DEBUG
	private let _osLogger: Logger
	#endif

	public init(subsystem: String, category: String) {
		self.subsystem = subsystem
		self.category = category
		#if DEBUG
		self._osLogger = Logger(subsystem: subsystem, category: category)
		#endif
	}

	public func debug(_ message: String) {
		AGLogFileWriter.shared.write(category: category, level: "debug", message: message)
		#if DEBUG
		_osLogger.debug("\(message)")
		#endif
	}

	public func info(_ message: String) {
		AGLogFileWriter.shared.write(category: category, level: "info", message: message)
		#if DEBUG
		_osLogger.info("\(message)")
		#endif
	}

	public func notice(_ message: String) {
		AGLogFileWriter.shared.write(category: category, level: "notice", message: message)
		#if DEBUG
		_osLogger.notice("\(message)")
		#endif
	}

	public func warning(_ message: String) {
		AGLogFileWriter.shared.write(category: category, level: "warning", message: message)
		#if DEBUG
		_osLogger.warning("\(message)")
		#endif
	}

	public func error(_ message: String) {
		AGLogFileWriter.shared.write(category: category, level: "error", message: message)
		#if DEBUG
		_osLogger.error("\(message)")
		#endif
	}

	public func fault(_ message: String) {
		AGLogFileWriter.shared.write(category: category, level: "fault", message: message)
		#if DEBUG
		_osLogger.fault("\(message)")
		#endif
	}
}
