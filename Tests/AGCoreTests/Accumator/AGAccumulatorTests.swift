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
		accumulator.event(event: .stop, at: 1)
		XCTAssertEqual(accumulator.state, .stopped)
		
		accumulator.event(event: .pause, at: 1)
		XCTAssertEqual(accumulator.state, .stopped)
		
		accumulator.event(event: .resume, at: 1)
		XCTAssertEqual(accumulator.state, .stopped)
		
		accumulator.event(event: .start, at: 1)
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startTimeInterval, 1)
		
		accumulator.event(event: .start, at: 2)
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startTimeInterval, 1)
		
		accumulator.event(event: .resume, at: 2)
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startTimeInterval, 1)
		
		accumulator.event(event: .pause, at: 2)
		XCTAssertEqual(accumulator.state, .paused)
		XCTAssertEqual(accumulator.startTimeInterval, 1)
		
		accumulator.event(event: .pause, at: 3)
		XCTAssertEqual(accumulator.state, .paused)
		XCTAssertEqual(accumulator.startTimeInterval, 1)
		
		accumulator.event(event: .resume, at: 4)
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startTimeInterval, 1)
		
		accumulator.event(event: .stop, at: 5)
		XCTAssertEqual(accumulator.state, .stopped)
		XCTAssertEqual(accumulator.startTimeInterval, 1)
		
		accumulator.event(event: .stop, at: 6)
		XCTAssertEqual(accumulator.state, .stopped)
		XCTAssertEqual(accumulator.startTimeInterval, 1)
		
	}
	
	func testAGAccumulatorAccumulate() throws {
		
		
		let accumulator = AGAccumulator()
		XCTAssertEqual(accumulator.state, .stopped)
		
		accumulator.event(event: .start, at: 5)
		XCTAssertEqual(accumulator.state, .running)
		XCTAssertEqual(accumulator.startTimeInterval, 5)
		
		try accumulator.accumulate(timeInterval: 5, value: 0, type: .distance)
		try accumulator.accumulate(timeInterval: 6, value: 1, type: .distance)
		try accumulator.accumulate(timeInterval: 7, value: 2, type: .distance)
		try accumulator.accumulate(timeInterval: 8, value: 3, type: .distance)
		try accumulator.accumulate(timeInterval: 9, value: 4, type: .distance)
		try accumulator.accumulate(timeInterval: 10, value: 5, type: .distance)
		
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .last), 5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulation), 5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulationOverTime), 1)
		
	}
	
	func testAGAccumulatorPause() throws {
		
		// start for 5 seconds
		let accumulator = AGAccumulator()
		accumulator.event(event: .start, at: 0)
		try accumulator.accumulate(timeInterval: 0, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 1, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 2, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 3, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 4, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 5, value: 1, type: .speed)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .last), 1)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .accumulation), 0)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .average), 1)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .accumulationOverTime), 0)

		try accumulator.accumulate(timeInterval: 0, value: 0, type: .distance)
		try accumulator.accumulate(timeInterval: 1, value: 1, type: .distance)
		try accumulator.accumulate(timeInterval: 2, value: 2, type: .distance)
		try accumulator.accumulate(timeInterval: 3, value: 3, type: .distance)
		try accumulator.accumulate(timeInterval: 4, value: 4, type: .distance)
		try accumulator.accumulate(timeInterval: 5, value: 5, type: .distance)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .last), 5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulation), 5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .average), 2.5)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulationOverTime), 1)

		
		// pause for 5 seconds
		accumulator.event(event: .pause, at: 5)

		// resume for 5 seconds
		accumulator.event(event: .resume, at: 10)
		
		try accumulator.accumulate(timeInterval: 10, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 11, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 12, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 13, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 14, value: 1, type: .speed)
		try accumulator.accumulate(timeInterval: 15, value: 1, type: .speed)
		
		try accumulator.accumulate(timeInterval: 10, value: 6, type: .distance)
		try accumulator.accumulate(timeInterval: 11, value: 7, type: .distance)
		try accumulator.accumulate(timeInterval: 12, value: 8, type: .distance)
		try accumulator.accumulate(timeInterval: 13, value: 9, type: .distance)
		try accumulator.accumulate(timeInterval: 14, value: 10, type: .distance)
		try accumulator.accumulate(timeInterval: 15, value: 11, type: .distance)
		
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .last), 1)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .accumulation), 0)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .average), 1)
		XCTAssertEqual(accumulator.lapData.currentData.data[.speed]?.getValue(for: .accumulationOverTime), 0)
		
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .last), 11)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulation), 11)
		XCTAssertEqual(accumulator.lapData.currentData.data[.distance]?.getValue(for: .average), 5.5)
		
		let value = try XCTUnwrap(accumulator.lapData.currentData.data[.distance]?.getValue(for: .accumulationOverTime))
		XCTAssertEqual(value, 0.7333, accuracy: 0.01)
		
		// stop
		accumulator.event(event: .stop, at: 15)
		
	}
}
