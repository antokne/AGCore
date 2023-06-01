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
		
		let date = Date()
		var accumData = AGAccumulatorData(startDate: date)
		accumData.add(type: .distance, date: date.plus(1), value: 1)
		
		XCTAssertNotNil(accumData.data[.distance])
		XCTAssertEqual(accumData.data[.distance]?.getValue(for: .first), 1)
	}
	
	func testAGAccumlatorMultiData() throws {
		
		let date = Date()
		var multiData = AGAccumulatorMultiData()
		multiData.start(startDate: date)
		XCTAssertTrue(multiData.previousData.isEmpty)
		XCTAssertNotNil(multiData.currentData)
		XCTAssertTrue(multiData.currentData.data.count == 1)
		XCTAssertEqual(multiData.currentData.data[.startTime]?.getValue(for: .last), date.timeIntervalSinceReferenceDate)

		multiData.add(type: .distance, date: date.plus(1), value: 1)
		
		XCTAssertTrue(multiData.previousData.isEmpty)
		XCTAssertNotNil(multiData.currentData.data.count == 1)
		
		multiData.rollCurrent(date: date.plus(2))
		XCTAssertFalse(multiData.previousData.isEmpty)
		XCTAssertNotNil(multiData.previousData.count == 1)

		XCTAssertNotNil(multiData.currentData)
		XCTAssertTrue(multiData.currentData.data.count == 1)
		XCTAssertEqual(multiData.currentData.data[.startTime]?.getValue(for: .last), date.plus(2).timeIntervalSinceReferenceDate)
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
	
	func testAccumulatedDataWithPause() throws {
				
		let date = Date()
		var accumData = AGAccumulatorData(startDate: date)
		accumData.add(type: .distance, date: date, value: 1)
		accumData.add(type: .distance, date: date.plus(1), value: 2)
		accumData.add(type: .distance, date: date.plus(2), value: 3)
		accumData.add(type: .distance, date: date.plus(3), value: 4)
		accumData.add(type: .distance, date: date.plus(4), value: 5)
		
		XCTAssertTrue(accumData.pause(date: date.plus(5)))
		
		// should be ignored
		accumData.add(type: .distance, date: date.plus(6), value: 111)
		
		XCTAssertTrue(accumData.resume(date: date.plus(10)))
	
		accumData.add(type: .distance, date: date.plus(11), value: 6)
		accumData.add(type: .distance, date: date.plus(12), value: 7)
		accumData.add(type: .distance, date: date.plus(13), value: 8)
		accumData.add(type: .distance, date: date.plus(14), value: 9)
		accumData.add(type: .distance, date: date.plus(15), value: 10)

		XCTAssertEqual(accumData.data[.distance]?.getValue(for: .last), 10)
		XCTAssertEqual(accumData.data[.distance]?.getValue(for: .max), 10)

		XCTAssertEqual(accumData.data[.startTime]?.getValue(for: .last), date.timeIntervalSinceReferenceDate)
		
		// worktime is total minue paused time.
		XCTAssertEqual(accumData.data[.workoutTime]?.getValue(for: .last), 10)
	}
	
	func testAccumulatedDistance() throws {
		
		let date = Date()
		var accumData = AGAccumulatorData(startDate: date)
		accumData.add(type: .distance, date: date, value: 0)
		accumData.add(type: .distance, date: date.plus(1), value: 1)
		accumData.add(type: .distance, date: date.plus(2), value: 2)
		accumData.add(type: .distance, date: date.plus(3), value: 3)
		accumData.add(type: .distance, date: date.plus(4), value: 4)
		accumData.add(type: .distance, date: date.plus(5), value: 5)

		XCTAssertEqual(accumData.data[.distance]?.getValue(for: .accumulation), 5)
		
		// this is alos avg speed which is right?
		XCTAssertEqual(accumData.data[.distance]?.getValue(for: .accumulationOverTime), 1)
	}
	
	func testAverageSpeed() throws {
		
		let date = Date()
		var accumData = AGAccumulatorData(startDate: date)
		accumData.add(type: .speed, date: date, value: 1)
		accumData.add(type: .speed, date: date.plus(1), value: 1)
		accumData.add(type: .speed, date: date.plus(2), value: 1)
		accumData.add(type: .speed, date: date.plus(3), value: 1)
		accumData.add(type: .speed, date: date.plus(4), value: 1)
		accumData.add(type: .speed, date: date.plus(5), value: 1)
		
		XCTAssertEqual(accumData.data[.speed]?.getValue(for: .average), 1)
	}
	
	func testAccumulatorRawData() throws {
		
		var data = AGAccumulatorRawData()
		
		XCTAssertTrue(data.data.isEmpty)
		
		data.add(value: AGDataTypeValue(type: .distance, value: 1), second: 1)
		XCTAssertFalse(data.data.isEmpty)
		XCTAssertEqual(data.data.count, 1)
		XCTAssertEqual(data.value(for: 1)?.value(for: .distance), 1)
		
		// only have one value for each time instance. overwrites.
		data.add(value: AGDataTypeValue(type: .distance, value: 2), second: 1)
		XCTAssertEqual(data.data.count, 1)
		XCTAssertEqual(data.value(for: 1)?.value(for: .distance), 2)
		var paused = try XCTUnwrap(data.value(for: 1)?.paused)
		XCTAssertFalse(paused)
		
		// paused
		data.add(value: AGDataTypeValue(type: .distance, value: 2), second: 2, paused: true)
		paused = try XCTUnwrap(data.value(for: 1)?.paused)
		XCTAssertFalse(paused)
		paused = try XCTUnwrap(data.value(for: 2)?.paused)
		XCTAssertTrue(paused)
		
		data.clear()
		XCTAssertTrue(data.data.isEmpty)

	}
}
