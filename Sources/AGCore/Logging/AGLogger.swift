//
//  AGLogger.swift
//
//
//  Created by Antony Gardiner on 20/06/23.
//

import Foundation
import OSLog
import UniformTypeIdentifiers

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

@MainActor
public class AGLogger {

	private var name: String
	private var subSystemPrefix: String
	private var positionSince: TimeInterval

	private var log = Logger(subsystem: "com.antokne.agcore", category: "AGLogger")

	public init(name: String, subSystemPrefix: String, duration: TimeInterval) {
		self.name = name
		self.subSystemPrefix = subSystemPrefix
		self.positionSince = duration
	}

	public func registerForNotifications() {
		NotificationCenter.default.addObserver(forName: NSNotification.Name.AGLoggerGenerateLog,
											   object: nil,
											   queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				self?.notificationReceived()
			}
		}
	}

	public func notificationReceived() {
		log.info("notificationReceived - generating logs.")
		Task {
			try? await generateLogFile()
		}
	}

	public func generateLogFile() async throws -> URL {

		// Always capture at least positionSince seconds. If a previous log exists and
		// is older than positionSince, extend the window to avoid gaps.
		var position = positionSince
		let newestLogFile = allLogFiles.max { first, second in first < second }
		if let newestLogFile, let newPositionDate = try newestLogFile.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate {
			log.info("newest position date = \(newPositionDate.formatted())")
			let sincePreviousLog = -newPositionDate.timeIntervalSinceNow + 1
			position = max(positionSince, sincePreviousLog)
			log.info("position = \(position)")
		}

		log.info("Generating logs from \(position)")
		let entries = try getLogEntries(positionSince: position)
		let url = generateLogFileURL()
		try writeToFile(entries: entries, to: url)
		log.info("Generating logs completed")
		return url
	}

	func getLogEntries(positionSince: TimeInterval) throws -> [OSLogEntryLog] {
		let logStore = try OSLogStore(scope: .currentProcessIdentifier)
		let dateFrom = Date().addingTimeInterval(-positionSince)
		log.info("Generating logs from date \(dateFrom.formatted())")
		let position = logStore.position(date: dateFrom)
		let allEntries = try logStore.getEntries(at: position)
		let osLogEntryLogObjects = allEntries.compactMap { $0 as? OSLogEntryLog }

		return osLogEntryLogObjects.filter { $0.subsystem.hasPrefix(subSystemPrefix) }
	}

	func writeToFile(entries: [OSLogEntryLog], to url: URL) throws {
		if FileManager.default.createFile(atPath: url.path(percentEncoded: false), contents: nil) == false {
			throw AGLoggerError.failedToCreateFile
		}

		let content = entries
			.map { generateLogMessage(entry: $0) + "\n" }
			.joined()

		guard let data = content.data(using: .utf8) else { return }
		let handle = try FileHandle(forWritingTo: url)
		try handle.write(contentsOf: data)
		try handle.close()
	}

	var logFileFolder: URL {
		URL.temporaryDirectory
	}

	func generateLogFileURL() -> URL {
		logFileFolder.appending(component: generateFileName(), directoryHint: .notDirectory)
	}

	func generateFileName() -> String {
		"\(Date.now.formatted(Self.filenameDateStyle))-\(name).log"
	}

	func generateLogMessage(entry: OSLogEntryLog) -> String {
		"\(entry.date.formatted(Self.logMessageDateStyle)) [\(entry.level.name)] \(entry.category): \(entry.composedMessage)"
	}

	// yyyy-MM-dd HH:mm:ss in local time — used in log file body
	private static let logMessageDateStyle = Date.VerbatimFormatStyle(
		format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)",
		timeZone: .current,
		calendar: .current
	)

	// yyyy-MM-dd-HHmmss in local time — colon-free for use in filenames
	private static let filenameDateStyle = Date.VerbatimFormatStyle(
		format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)-\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))\(minute: .twoDigits)\(second: .twoDigits)",
		timeZone: .current,
		calendar: .current
	)

	public var allLogFiles: Set<AGLogFile> {

		var logFiles: Set<AGLogFile> = []
		do {
			let files = try FileManager.default.contentsOfDirectory(at: logFileFolder, includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey])
			for file in files {
				if file.pathExtension == "log" && file.lastPathComponent.contains(name) {
					logFiles.insert(AGLogFile(logFileURL: file))
				}
			}
		}
		catch {
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
		let lhsDate = (try? lhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
		let rhsDate = (try? rhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
		return lhsDate < rhsDate
	}

}
