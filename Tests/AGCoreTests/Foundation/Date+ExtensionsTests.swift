//
//  Date+ExtensionsTests.swift
//
//
//  Created by Ant Gardiner on 21/09/23.
//

import XCTest

final class Date_ExtensionsTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testStartOfWeek() throws {
		
		let RFC3339DateFormatter = DateFormatter.RFC3339DateFormatter()
		
		let string = "2022-12-19T10:39:57-00:00"
		let date = try XCTUnwrap(RFC3339DateFormatter.date(from: string))
		
		let startOfWeek = try XCTUnwrap(date.startOfWeek)
		let sowString = RFC3339DateFormatter.string(from: startOfWeek)
		XCTAssertEqual(sowString, "2022-12-19T00:00:00+13:00")
		
	}

	func testAddSecond() throws {
		
		var now = Date()
		let anotherDate = now.plus(3)

		now.addTimeInterval(3)
		
		XCTAssertEqual(now, anotherDate)
		
	}
}
