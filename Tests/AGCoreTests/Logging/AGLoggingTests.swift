//
//  AGLoggingTests.swift
//
//
//  Created by Antony Gardiner on 20/06/23.
//

import XCTest
@testable import AGCore

final class AGLoggingTests: XCTestCase {

	override func setUp() async throws {
		// Give the file writer a deterministic name so teardown can clean up.
		AGLogFileWriter.shared.configure(name: "TEST")
	}

	override func tearDown() async throws {
		let files = AGLogFileWriter.shared.allLogFiles.map { $0.logFileURL }
		AGLogFileWriter.shared.delete(logs: Set(files))
	}

	func testGenerateFileName() {
		let name = AGLogFileWriter.shared.generateFileName()
		XCTAssertTrue(name.contains("-TEST.log"))
		XCTAssertTrue(name.hasSuffix(".log"))
	}

	func testGenerateLogFileURL() {
		let url = AGLogFileWriter.shared.generateFileURL()
		XCTAssertTrue(url.path(percentEncoded: false).contains("/tmp/"))
		XCTAssertTrue(url.path(percentEncoded: false).contains("-TEST"))
		XCTAssertTrue(url.path(percentEncoded: false).hasSuffix(".log"))
	}

	func testWriteLogsToFile() throws {
		let logger = AGLogger(subsystem: "com.antokne.agcore", category: "AGLoggingTests")
		logger.info("A log test message")

		let url = try XCTUnwrap(AGLogFileWriter.shared.roll())
		let contents = try String(contentsOf: url)

		XCTAssertTrue(contents.contains("[info]"))
		XCTAssertTrue(contents.contains("AGLoggingTests"))
		XCTAssertTrue(contents.contains("A log test message"))

		try? FileManager.default.removeItem(at: url)
	}

	func testMultipleLogs() throws {
		let logger = AGLogger(subsystem: "com.antokne.agcore", category: "AGLoggingTests")
		logger.info("First message")

		let url1 = try XCTUnwrap(AGLogFileWriter.shared.roll())
		let contents1 = try String(contentsOf: url1)
		XCTAssertTrue(contents1.contains("First message"))

		logger.error("Second message")

		let url2 = try XCTUnwrap(AGLogFileWriter.shared.roll())
		let contents2 = try String(contentsOf: url2)
		XCTAssertTrue(contents2.contains("[error]"))
		XCTAssertTrue(contents2.contains("Second message"))
		XCTAssertFalse(contents2.contains("First message"))

		XCTAssertEqual(AGLogFileWriter.shared.allLogFiles.count, 2)
	}

	func testLogManagerGenerateLogFile() async throws {
		let manager = await AGLogManager(name: "TEST")
		let logger = AGLogger(subsystem: "com.antokne.agcore", category: "AGLoggingTests")
		logger.info("Manager test message")

		let url = try await manager.generateLogFile()
		let contents = try String(contentsOf: url)

		XCTAssertTrue(contents.contains("Manager test message"))
		XCTAssertTrue(url.lastPathComponent.hasSuffix(".log"))
	}
}
