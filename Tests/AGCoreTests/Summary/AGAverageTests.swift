//
//  AGAverageTests.swift
//  
//
//  Created by Antony Gardiner on 27/02/23.
//

import XCTest
@testable import AGCore

final class AGAverageTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testAverages() {

		var average = AGAverage(type: .power)
		
		let left = CGPoint(x: 10, y: 2)
		let max = CGPoint(x: 12, y: 6)
		let min = CGPoint(x: 13, y: 1)
		let right = CGPoint(x: 14, y: 3)
		let count = 4
		let accum_over_time = (right.y - left.y)/(right.x - left.x)
		
		average.add(point: left)
		average.add(point: max)
		average.add(point: min)
		average.add(point: right)

		print(average.stringValue())
		
		XCTAssertEqual(average.count, count)
		XCTAssertEqual(average.getValue(for: .first), left.y)
		XCTAssertEqual(average.getValue(for: .last), right.y)
		XCTAssertEqual(average.getValue(for: .min), min.y)
		XCTAssertEqual(average.getValue(for: .max), max.y)
		XCTAssertEqual(average.getValue(for: .range), max.y - min.y)
		XCTAssertEqual(average.getValue(for: .accumulation), right.y - left.y)
		XCTAssertEqual(average.getValue(for: .accumulationOverTime), accum_over_time)

	}
	
}
