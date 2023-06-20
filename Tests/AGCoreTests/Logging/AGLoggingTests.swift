//
//  AGLoggingTests.swift
//  
//
//  Created by Antony Gardiner on 20/06/23.
//

import XCTest
import OSLog
@testable import AGCore

final class AGLoggingTests: XCTestCase {
	
	let dateFormatter = DateFormatter()

	override func setUpWithError() throws {
		dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
	}
	
	override func tearDownWithError() throws {
	}
	
	func testGenerateFileName() throws {

		let date = Date()
		let logger = AGLogger(name: "bob", subSystemPrefix: "dfdsf", duration: 2)
		let fileName = logger.generateFileName()
		
		let checkFileName = "\(dateFormatter.string(from: date))-bob.log"
		
		XCTAssertEqual(fileName, checkFileName)
	}
	
	func testGenerateLogFileURL() throws {
		
		let date = Date()
		let logger = AGLogger(name: "bob", subSystemPrefix: "dfdsf", duration: 2)
		let logFileName = logger.generateLogFileURL()
		
		let dateString = dateFormatter.string(from: date)

		XCTAssertTrue(logFileName.path(percentEncoded: false).contains(dateString))
		XCTAssertTrue(logFileName.path(percentEncoded: false).contains("-bob"))
		XCTAssertTrue(logFileName.path(percentEncoded: false).contains("/tmp/"))
		XCTAssertTrue(logFileName.path(percentEncoded: false).hasSuffix(".log"))
	}
	
	func testGetLogEntries() throws {
		
		let logger = Logger(subsystem: "com.antokne.agcore", category: "AGLoggingTests")
		logger.info("A log test message")
		
		let agLogger = AGLogger(name: "BOB", subSystemPrefix: "com.antokne", duration: 1)
		
		let entries = try XCTUnwrap(agLogger.getLogEntries())
		
		XCTAssertTrue(entries.count >= 1)
		
		let first = try XCTUnwrap(entries.first)
		
		let message = agLogger.generateLogMessage(entry: first)
		XCTAssertTrue(message.contains("[info]"))
		XCTAssertTrue(message.contains("AGLoggingTests"))
		XCTAssertTrue(message.hasSuffix("A log test message"))
	}
	
	func testWriteLogsToFile() async throws {
		
		let logger = Logger(subsystem: "com.antokne.agcore", category: "AGLoggingTests")
		logger.info("A log test message")
		
		let agLogger = AGLogger(name: "BOB", subSystemPrefix: "com.antokne", duration: 1)
		
		let url = try await agLogger.generateLogFile()
		
		let contents = try String(contentsOf: url)
		
		XCTAssertTrue(contents.contains("[info]"))
		XCTAssertTrue(contents.contains("AGLoggingTests"))
		XCTAssertTrue(contents.hasSuffix("A log test message\n"))
		
		try? FileManager.default.removeItem(at: url)
	}
	
}
