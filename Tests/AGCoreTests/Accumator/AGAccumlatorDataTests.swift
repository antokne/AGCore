//
//  AGAccumlatorDataTests.swift
//  
//
//  Created by Antony Gardiner on 29/05/23.
//

import XCTest
@testable import AGCore

final class AGAccumlatorDataTests: XCTestCase {
	
	override func setUpWithError() throws {
		
	}
	
	override func tearDownWithError() throws {
		
	}
	
	func testAccumlatorData() throws {
		
		var accumData = AGAccumulatorData()
		accumData.add(type: .distance, seconds: 1, value: 1)
		
		XCTAssertNotNil(accumData.data[.distance])
		XCTAssertEqual(accumData.data[.distance]?.getValue(for: .first), 1)
	}
	
	
	func testAGAccumlatorMultiData() throws {
		
		var multiData = AGAccumlatorMultiData()
		XCTAssertTrue(multiData.previousData.isEmpty)
		XCTAssertNotNil(multiData.currentData)
		XCTAssertTrue(multiData.currentData.data.isEmpty)

		multiData.add(type: .distance, seconds: 1, value: 1)
		
		XCTAssertTrue(multiData.previousData.isEmpty)
		XCTAssertNotNil(multiData.currentData.data.count == 1)
		
		multiData.rollCurrent()
		XCTAssertFalse(multiData.previousData.isEmpty)
		XCTAssertNotNil(multiData.previousData.count == 1)

		XCTAssertNotNil(multiData.currentData)
		XCTAssertTrue(multiData.currentData.data.isEmpty)

	}
	
	func testAGAccumulatorPausedData() {
		
		
		var pausedData = AGAccumulatorPausedData()
		XCTAssertFalse(pausedData.paused)
		XCTAssertEqual(pausedData.pausedTimeS, 0)
		XCTAssertNil(pausedData.pausedStartTimeInterval)
		
		// not pause this will do nothing
		pausedData.resume(timeInterval: 2000)
		XCTAssertFalse(pausedData.paused)
		XCTAssertEqual(pausedData.pausedTimeS, 0)
		XCTAssertNil(pausedData.pausedStartTimeInterval)

		pausedData.pause(timeInterval: 1)
		XCTAssertEqual(pausedData.pausedStartTimeInterval, 1)
		XCTAssertTrue(pausedData.paused)
		XCTAssertEqual(pausedData.pausedTimeS, 0)

		// pausing when paused will do nothing
		pausedData.pause(timeInterval: 1)
		XCTAssertEqual(pausedData.pausedStartTimeInterval, 1)
		XCTAssertTrue(pausedData.paused)
		XCTAssertEqual(pausedData.pausedTimeS, 0)

		pausedData.resume(timeInterval: 2)
		XCTAssertFalse(pausedData.paused)
		XCTAssertNil(pausedData.pausedStartTimeInterval)
		XCTAssertEqual(pausedData.pausedTimeS, 1)
		
	}
}
