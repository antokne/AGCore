//
//  AGLogFileWriter.swift
//
//
//  Created by Ant Gardiner on 2026-05-06.
//

import Foundation

/// Maximum size of a single log file before rolling (5 MB).
let agLogFileMaxSize = 5 * 1024 * 1024

/// Number of rolling log files to keep on disk.
let agLogFileMaxCount = 5

/// Internal singleton that handles writing log lines to a rolling set of files.
/// All mutable state is protected by `lock`; access never crosses the lock boundary without it held.
final class AGLogFileWriter: @unchecked Sendable {

	static let shared = AGLogFileWriter()

	private let lock = NSLock()
	private(set) var logName: String = "app"

	private var fileHandle: FileHandle?
	private var currentFileURL: URL?
	private var currentFileSize: Int = 0

	private init() {}

	/// Sets the base name used in log file names. Call once at startup from `AGLogManager.init`.
	func configure(name: String) {
		lock.lock()
		defer { lock.unlock() }
		logName = name
	}

	/// Appends a formatted log line to the current file, rolling if needed.
	func write(category: String, level: String, message: String) {
		let line = "\(Date.now.formatted(Self.logDateStyle)) [\(level)] \(category): \(message)\n"
		guard let data = line.data(using: .utf8) else { return }
		lock.lock()
		defer { lock.unlock() }
		ensureFileOpen()
		try? fileHandle?.write(contentsOf: data)
		currentFileSize += data.count
		if currentFileSize >= agLogFileMaxSize {
			rollFileInternal()
		}
	}

	/// Seals the current file (closing it) and opens a fresh one.
	/// Returns the URL of the sealed file, or nil if nothing has been written yet.
	func roll() -> URL? {
		lock.lock()
		defer { lock.unlock() }
		let sealed = currentFileURL
		rollFileInternal()
		return sealed
	}

	var allLogFiles: Set<AGLogFile> {
		lock.lock()
		defer { lock.unlock() }
		return logFilesInternal(name: logName)
	}

	func delete(logs: Set<URL>) {
		for url in logs {
			try? FileManager.default.removeItem(at: url)
		}
	}

	// MARK: - Internal helpers (must be called with lock held)

	private func ensureFileOpen() {
		guard fileHandle == nil else { return }
		openNewFileInternal()
	}

	private func openNewFileInternal() {
		let url = generateFileURL()
		FileManager.default.createFile(atPath: url.path(percentEncoded: false), contents: nil)
		fileHandle = try? FileHandle(forWritingTo: url)
		currentFileURL = url
		currentFileSize = 0
		pruneOldFilesInternal()
	}

	private func rollFileInternal() {
		try? fileHandle?.close()
		fileHandle = nil
		currentFileURL = nil
		currentFileSize = 0
		openNewFileInternal()
	}

	private func logFilesInternal(name: String) -> Set<AGLogFile> {
		var result: Set<AGLogFile> = []
		let files = (try? FileManager.default.contentsOfDirectory(
			at: URL.temporaryDirectory,
			includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey]
		)) ?? []
		for file in files where file.pathExtension == "log" && file.lastPathComponent.contains(name) {
			result.insert(AGLogFile(logFileURL: file))
		}
		return result
	}

	private func pruneOldFilesInternal() {
		let files = logFilesInternal(name: logName).sorted()
		guard files.count > agLogFileMaxCount else { return }
		for file in files.dropLast(agLogFileMaxCount) {
			try? FileManager.default.removeItem(at: file.logFileURL)
		}
	}

	// MARK: - File naming

	func generateFileURL() -> URL {
		URL.temporaryDirectory.appending(component: generateFileName(), directoryHint: .notDirectory)
	}

	func generateFileName() -> String {
		"\(Date.now.formatted(Self.filenameDateStyle))-\(logName).log"
	}

	// MARK: - Date styles

	// yyyy-MM-dd HH:mm:ss in local time — used in log file body
	static let logDateStyle = Date.VerbatimFormatStyle(
		format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)",
		timeZone: .current,
		calendar: .current
	)

	// yyyy-MM-dd-HHmmss colon-free for filenames
	static let filenameDateStyle = Date.VerbatimFormatStyle(
		format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)-\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))\(minute: .twoDigits)\(second: .twoDigits)",
		timeZone: .current,
		calendar: .current
	)
}
