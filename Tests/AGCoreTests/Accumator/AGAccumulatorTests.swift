//
//  AGAccumulatorTests.swift
//  
//
//  Created by Antony Gardiner on 29/05/23.
//

import XCTest
@testable import AGCore

final class AGAccumulatorTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testAGAccumulatorStates() throws {
		
		let accumulator = AGAccumulator()
		XCTAssertEqual(accumulator.state, .stopped)
		
		// will still be stopped
		let date = Date()
		accumulator.event(event: .stop, at: date)
		XCTAssertEqual(accumulator.state, .stopped)
		
		accumulator.event(event: .pause, at: date)
		XCTAssertEqual(accumulator.state, .stopped)
		
		accumulator.event(event: .resume, at: date)
		XCTAssertEqual(accumulator.state, .stopped)
		
		accumulator.event(event: .start, at: date)
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startDate, date)
		
		accumulator.event(event: .start, at: date)
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startDate, date)
		
		let date2 = date.addingTimeInterval(2)
		accumulator.event(event: .resume, at: date2)
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startDate, date)
		
		accumulator.event(event: .pause, at: date2)
		XCTAssertEqual(accumulator.state, .paused)
		XCTAssertEqual(accumulator.startDate, date)
		
		accumulator.event(event: .pause, at: date2.addingTimeInterval(1))
		XCTAssertEqual(accumulator.state, .paused)
		XCTAssertEqual(accumulator.startDate, date)
		
		accumulator.event(event: .resume, at: date2.addingTimeInterval(2))
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startDate, date)
		
		accumulator.event(event: .stop, at: date2.addingTimeInterval(3))
		XCTAssertEqual(accumulator.state, .stopped)
		XCTAssertEqual(accumulator.startDate, date)
		
		accumulator.event(event: .stop, at: date2.addingTimeInterval(4))
		XCTAssertEqual(accumulator.state, .stopped)
		XCTAssertEqual(accumulator.startDate, date)
		
	}
	
	func testAGAccumulatorAccumulate() throws {
		
		
		let accumulator = AGAccumulator()
		XCTAssertEqual(accumulator.state, .stopped)
		
		let date = Date()
		accumulator.event(event: .start, at: date)
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startDate, date)
		
		try accumulator.accumulate(date: date.plus(10), value: 0, type: .distance)
		try accumulator.accumulate(date: date.plus(11), value: 1, type: .distance)
		try accumulator.accumulate(date: date.plus(12), value: 2, type: .distance)
		try accumulator.accumulate(date: date.plus(13), value: 3, type: .distance)
		try accumulator.accumulate(date: date.plus(14), value: 4, type: .distance)
		try accumulator.accumulate(date: date.plus(15), value: 5, type: .distance)
		
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .last), 5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulation), 5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulationOverTime), 1)
		
	}
	
	func testAGAccumulatorPause() throws {
		
		// start for 5 seconds
		let accumulator = AGAccumulator()
		let date = Date()
		accumulator.event(event: .start, at: date)
		try accumulator.accumulate(date: date, value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(1), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(2), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(3), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(4), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(5), value: 1, type: .speed)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .last), 1)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .accumulation), 0)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .average), 1)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .accumulationOverTime), 0)

		try accumulator.accumulate(date: date, value: 0, type: .distance)
		try accumulator.accumulate(date: date.plus(1), value: 1, type: .distance)
		try accumulator.accumulate(date: date.plus(2), value: 2, type: .distance)
		try accumulator.accumulate(date: date.plus(3), value: 3, type: .distance)
		try accumulator.accumulate(date: date.plus(4), value: 4, type: .distance)
		try accumulator.accumulate(date: date.plus(5), value: 5, type: .distance)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .last), 5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulation), 5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .average), 2.5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulationOverTime), 1)

		
		// pause for 5 seconds
		let datePause = date.plus(5)
		accumulator.event(event: .pause, at: datePause)
		XCTAssertEqual(accumulator.state, .paused)

		// resume for 5 seconds
		let dateResume = date.plus(10)

		accumulator.event(event: .resume, at: dateResume)
		XCTAssertEqual(accumulator.state, .running)

		try accumulator.accumulate(date: dateResume, value: 1, type: .speed)
		try accumulator.accumulate(date: dateResume.plus(1), value: 1, type: .speed)
		try accumulator.accumulate(date: dateResume.plus(2), value: 1, type: .speed)
		try accumulator.accumulate(date: dateResume.plus(3), value: 1, type: .speed)
		try accumulator.accumulate(date: dateResume.plus(4), value: 1, type: .speed)
		try accumulator.accumulate(date: dateResume.plus(5), value: 1, type: .speed)
		
//		try accumulator.accumulate(date: dateResume, value: 6, type: .distance)
		try accumulator.accumulate(date: dateResume.plus(1), value: 6, type: .distance)
		try accumulator.accumulate(date: dateResume.plus(2), value: 7, type: .distance)
		try accumulator.accumulate(date: dateResume.plus(3), value: 8, type: .distance)
		try accumulator.accumulate(date: dateResume.plus(4), value: 9, type: .distance)
		try accumulator.accumulate(date: dateResume.plus(5), value: 10, type: .distance)
		
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .last), 1)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .accumulation), 0)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .average), 1)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .accumulationOverTime), 0)
		
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .last), 10)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulation), 10)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .average), 5.0)
		
		let value = try XCTUnwrap(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulationOverTime))
		XCTAssertEqual(value, 1.00, accuracy: 0.01)
		
		// nothing should happen, ignore.
		accumulator.event(event: .reset, at: dateResume.plus(5))
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .average), 5.0)
		
		// stop
		accumulator.event(event: .stop, at: dateResume.plus(5))
		
		accumulator.event(event: .reset, at: dateResume.plus(6))
		XCTAssertTrue(accumulator.lapData.currentData.data.count == 1)
		XCTAssertNotNil(accumulator.lapData.currentData.data[.startTime]?.getValue(for: .last))

	}
}

