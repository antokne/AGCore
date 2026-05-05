//
//  AGLogManager.swift
//
//
//  Created by Ant Gardiner on 2026-05-06.
//

import Foundation

/// Manages the set of rolling log files and coordinates log generation for upload or sharing.
/// Create one instance at app startup; it configures the shared `AGLogFileWriter` with the
/// given name so all subsequent `AGLogger` writes use that name in their file names.
@MainActor
public class AGLogManager {

	private let name: String
	private let log = AGLogger(subsystem: "com.antokne.agcore", category: "AGLogManager")

	public init(name: String) {
		self.name = name
		AGLogFileWriter.shared.configure(name: name)
	}

	public func registerForNotifications() {
		NotificationCenter.default.addObserver(
			forName: .AGLoggerGenerateLog,
			object: nil,
			queue: .main
		) { [weak self] _ in
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

	/// Seals the current log file and returns its URL. Opens a fresh file for subsequent writes.
	/// Throws `AGLoggerError.failedToCreateFile` if no data has been written yet.
	public func generateLogFile() async throws -> URL {
		log.info("generateLogFile called")
		guard let url = AGLogFileWriter.shared.roll() else {
			throw AGLoggerError.failedToCreateFile
		}
		log.info("generateLogFile completed: \(url.lastPathComponent)")
		return url
	}

	public var allLogFiles: Set<AGLogFile> {
		AGLogFileWriter.shared.allLogFiles
	}

	public func delete(logs: Set<URL>) {
		AGLogFileWriter.shared.delete(logs: logs)
	}

	// MARK: - Internal helpers (used by tests)

	func generateFileName() -> String {
		AGLogFileWriter.shared.generateFileName()
	}

	func generateLogFileURL() -> URL {
		AGLogFileWriter.shared.generateFileURL()
	}
}
