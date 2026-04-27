//
//  AGBackgroundUploadSession.swift
//
//
//  Created by Ant Gardiner on 2026-04-27.
//
//  Background URLSession wrapper for the upload (file-transfer) step of
//  cloud share flows. Login still happens in the foreground via an
//  ephemeral session — only the multipart POST is moved here so the
//  transfer survives app suspension and termination.
//

import Foundation
import os

/// Opaque metadata persisted alongside a background upload task so that
/// callers can correlate a relaunch-delivered completion back to the
/// originating activity / share site.
public struct AGBackgroundUploadMetadata: Codable, Sendable {
	/// `URIRepresentation()` of the activity's NSManagedObjectID.
	public let activityObjectIDURI: String
	/// Display name of the share site (matches `ActivityShareSite.siteName`).
	public let shareSiteName: String
	/// Local file URL of the FIT file being uploaded.
	public let fileURLString: String

	public init(activityObjectIDURI: String, shareSiteName: String, fileURLString: String) {
		self.activityObjectIDURI = activityObjectIDURI
		self.shareSiteName = shareSiteName
		self.fileURLString = fileURLString
	}
}

public typealias AGBackgroundUploadResult = Result<(Data, HTTPURLResponse), Error>

/// Closure invoked when a background-upload completion arrives without an
/// in-memory continuation waiting for it (i.e. the app was relaunched by
/// iOS to deliver the result).
public typealias AGBackgroundUploadRelaunchHandler = @Sendable (AGBackgroundUploadMetadata, AGBackgroundUploadResult) async -> Void

public enum AGBackgroundUploadError: Error {
	case sessionInvalidated
	case missingResponse
}

/// Singleton wrapper around a single background `URLSession`.
///
/// Background sessions with a given identifier must not be re-instantiated
/// while one is alive — the system enforces this with a crash. Always go
/// through `AGBackgroundUploadSession.shared`.
public final class AGBackgroundUploadSession: NSObject, @unchecked Sendable {

	public static let shared = AGBackgroundUploadSession()

	private let logger = Logger(subsystem: "com.antokne.core", category: "AGBackgroundUploadSession")

	// All shared mutable state guarded by `lock`. The delegate callbacks
	// arrive on the session's `delegateQueue` (a private serial queue) and
	// the public `upload` API is callable from any actor — the lock
	// preserves invariants without forcing every API onto an actor.
	private let lock = NSLock()
	private var continuations: [Int: CheckedContinuation<(Data, HTTPURLResponse), Error>] = [: ]
	private var responseData: [Int: Data] = [: ]
	private var pendingMetadata: [Int: AGBackgroundUploadMetadata] = [: ]
	private var relaunchHandler: AGBackgroundUploadRelaunchHandler?
	private var backgroundEventsContinuations: [CheckedContinuation<Void, Never>] = []

	private lazy var session: URLSession = {
		URLSession(configuration: AGSessionConfiguration.backgroundSessionConfiguration,
				   delegate: self,
				   delegateQueue: nil)
	}()

	override private init() {
		super.init()
		// Force session creation early so the system can deliver pending
		// completions to our delegate as soon as we're alive (notably on
		// iOS-initiated relaunch).
		_ = session
		loadPendingMetadata()
		lock.lock()
		let pendingCount = pendingMetadata.count
		let pendingKeys = pendingMetadata.keys.sorted()
		lock.unlock()
		logger.info("AGBackgroundUploadSession init id=\(AGSessionConfiguration.backgroundUploadIdentifier, privacy: .public) restored \(pendingCount, privacy: .public) pending metadata entries keys=\(pendingKeys, privacy: .public)")
	}

	// MARK: - Public API

	/// Register a handler invoked when an upload finishes without a live
	/// continuation. Call this once during app launch.
	public func setRelaunchHandler(_ handler: @escaping AGBackgroundUploadRelaunchHandler) {
		lock.lock()
		relaunchHandler = handler
		lock.unlock()
		logger.info("Relaunch handler registered")
	}

	/// Enqueue a multipart upload on the background session. The returned
	/// tuple matches `URLSession.data(for:)` so call sites can inspect the
	/// HTTP status code.
	public func upload(fileURL: URL,
					   request: URLRequest,
					   metadata: AGBackgroundUploadMetadata) async throws -> (Data, HTTPURLResponse) {

		let task = session.uploadTask(with: request, fromFile: fileURL)
		let identifier = task.taskIdentifier

		logger.info("Enqueue upload taskId=\(identifier, privacy: .public) site=\(metadata.shareSiteName, privacy: .public) activity=\(metadata.activityObjectIDURI, privacy: .public) file=\(fileURL.lastPathComponent, privacy: .public)")

		return try await withCheckedThrowingContinuation { continuation in
			lock.lock()
			continuations[identifier] = continuation
			pendingMetadata[identifier] = metadata
			responseData[identifier] = Data()
			lock.unlock()
			persistPendingMetadata()
			task.resume()
			logger.debug("Upload task resumed taskId=\(identifier, privacy: .public)")
		}
	}

	/// Awaits delivery of all pending background-session events. Should be
	/// called from `.backgroundTask(.urlSession(<identifier>))` in the
	/// SwiftUI scene.
	public func handleEventsForBackgroundURLSession() async {
		logger.info("handleEventsForBackgroundURLSession: awaiting urlSessionDidFinishEvents")
		await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
			lock.lock()
			backgroundEventsContinuations.append(continuation)
			lock.unlock()
		}
		logger.info("handleEventsForBackgroundURLSession: completed")
	}

	// MARK: - Metadata persistence

	private static let metadataFileURL: URL = {
		let dir = URL.applicationSupportDirectory
		try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
		return dir.appending(path: "AGBackgroundUploadSession.json")
	}()

	private func persistPendingMetadata() {
		lock.lock()
		let snapshot: [String: AGBackgroundUploadMetadata] = pendingMetadata.reduce(into: [: ]) { acc, entry in
			acc[String(entry.key)] = entry.value
		}
		lock.unlock()

		do {
			let data = try JSONEncoder().encode(snapshot)
			try data.write(to: Self.metadataFileURL, options: [.atomic])
		} catch {
			logger.error("Failed to persist pending metadata: \(error)")
		}
	}

	private func loadPendingMetadata() {
		guard let data = try? Data(contentsOf: Self.metadataFileURL),
			  let stored = try? JSONDecoder().decode([String: AGBackgroundUploadMetadata].self, from: data) else {
			return
		}
		lock.lock()
		for (key, value) in stored {
			if let identifier = Int(key) {
				pendingMetadata[identifier] = value
			}
		}
		lock.unlock()
	}

	private func removeMetadata(for identifier: Int) {
		lock.lock()
		pendingMetadata[identifier] = nil
		lock.unlock()
		persistPendingMetadata()
	}
}

// MARK: - URLSessionDataDelegate / URLSessionTaskDelegate

extension AGBackgroundUploadSession: URLSessionDataDelegate, URLSessionTaskDelegate {

	public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		let identifier = dataTask.taskIdentifier
		lock.lock()
		responseData[identifier, default: Data()].append(data)
		let total = responseData[identifier]?.count ?? 0
		lock.unlock()
		logger.debug("didReceive taskId=\(identifier, privacy: .public) chunk=\(data.count, privacy: .public) total=\(total, privacy: .public)")
	}

	public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
		logger.debug("didSendBodyData taskId=\(task.taskIdentifier, privacy: .public) sent=\(totalBytesSent, privacy: .public)/\(totalBytesExpectedToSend, privacy: .public)")
	}

	public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

		let identifier = task.taskIdentifier

		lock.lock()
		let continuation = continuations.removeValue(forKey: identifier)
		let body = responseData.removeValue(forKey: identifier) ?? Data()
		let metadata = pendingMetadata[identifier]
		let handler = relaunchHandler
		lock.unlock()

		let result: AGBackgroundUploadResult
		if let error = error {
			logger.error("didCompleteWithError taskId=\(identifier, privacy: .public) bytes=\(body.count, privacy: .public) error=\(error, privacy: .public)")
			result = .failure(error)
		} else if let response = task.response as? HTTPURLResponse {
			logger.info("didComplete taskId=\(identifier, privacy: .public) status=\(response.statusCode, privacy: .public) bytes=\(body.count, privacy: .public) site=\(metadata?.shareSiteName ?? "?", privacy: .public)")
			result = .success((body, response))
		} else {
			logger.error("didComplete taskId=\(identifier, privacy: .public) missingResponse")
			result = .failure(AGBackgroundUploadError.missingResponse)
		}

		if let continuation = continuation {
			logger.debug("Resuming live continuation for taskId=\(identifier, privacy: .public)")
			switch result {
			case .success(let payload):
				continuation.resume(returning: payload)
			case .failure(let error):
				continuation.resume(throwing: error)
			}
			removeMetadata(for: identifier)
			return
		}

		// No live continuation — relaunch / out-of-process delivery.
		if let metadata = metadata, let handler = handler {
			logger.info("Routing taskId=\(identifier, privacy: .public) to relaunch handler site=\(metadata.shareSiteName, privacy: .public) activity=\(metadata.activityObjectIDURI, privacy: .public)")
			Task {
				await handler(metadata, result)
				self.removeMetadata(for: identifier)
			}
		} else {
			logger.warning("Upload task \(identifier, privacy: .public) completed with no continuation and no relaunch handler — dropping result hasMetadata=\(metadata != nil, privacy: .public) hasHandler=\(handler != nil, privacy: .public)")
			removeMetadata(for: identifier)
		}
	}

	public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
		lock.lock()
		let waiters = backgroundEventsContinuations
		backgroundEventsContinuations.removeAll()
		lock.unlock()
		logger.info("urlSessionDidFinishEvents firing \(waiters.count, privacy: .public) waiter(s)")
		for waiter in waiters {
			waiter.resume()
		}
	}
}
