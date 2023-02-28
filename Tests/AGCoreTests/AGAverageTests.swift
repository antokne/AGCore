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
		
		for x in 0...10 {
			let y = x
			average.add(x: Double(x), y: Double(y))
		}
		
		print(average.stringValue())
		
		XCTAssertEqual(average.getValue(for: .first), 0.0)
		XCTAssertEqual(average.getValue(for: .last), 10.0)
		XCTAssertEqual(average.getValue(for: .min), 0.0)
		XCTAssertEqual(average.getValue(for: .max), 10.0)
		XCTAssertEqual(average.getValue(for: .range), 10.0)
		XCTAssertEqual(average.getValue(for: .accumulation), 10.0)
		XCTAssertEqual(average.getValue(for: .accumulationOverTime), 1000.0)

	}
	
}
