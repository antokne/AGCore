//
//  AGMovingAverageTests.swift
//  
//
//  Created by Antony Gardiner on 27/02/23.
//

import XCTest
@testable import AGCore

final class AGMovingAverageTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testMovingAverage() throws {
		
		let movingAverage30s = AGMovingAverage(ms: 30000)
		
		var sum: Double = 0.0
		
		for ms in 1000...31000 {
			
			// every second
			if ms % 1000 == 0 {
				
				let y = ms / 1000
				sum += Double(y)
				movingAverage30s.add(ms: ms, value: Double(y))
				
			}
		}
		
		print(movingAverage30s.stringValue)
		
		XCTAssertEqual(movingAverage30s.sum, sum)
		XCTAssertEqual(movingAverage30s.getValue(for: .min), 1)
		XCTAssertEqual(movingAverage30s.getValue(for: .max), 31)
		XCTAssertEqual(movingAverage30s.getValue(for: .average), sum / 31)
		XCTAssertEqual(movingAverage30s.getValue(for: .accumulationOverTime), 1.0)


		movingAverage30s.add(ms: 32000, value: 32)
		
		
		XCTAssertEqual(movingAverage30s.sum, sum + 32 - 1)
		XCTAssertEqual(movingAverage30s.getValue(for: .min), 2)
		XCTAssertEqual(movingAverage30s.getValue(for: .max), 32)
		XCTAssertEqual(movingAverage30s.getValue(for: .average), (sum + 32 - 1) / 31)
		XCTAssertEqual(movingAverage30s.getValue(for: .accumulationOverTime), 1.0)
		
		movingAverage30s.add(ms: 32000, value: 32)

	}
	
	
}
