//
//  AGDataTypeTests.swift
//  
//
//  Created by Antony Gardiner on 14/06/23.
//

import XCTest
@testable import AGCore

final class AGDataTypeTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testDataTypeFomatting() throws {
		
	
		XCTAssertTrue(AGDataType.speed.units == UnitSpeed.metersPerSecond)
		
		let metric = Locale.current.measurementSystem == .metric
		let units = metric ? UnitSpeed.kilometersPerHour : UnitSpeed.milesPerHour
		
		XCTAssertTrue(AGDataType.speed.displayedDimension == units)

		let speedMps = 11.0
		let speed = metric ? "39.6" : "24.6"
		
		let result = AGDataType.speed.format(value: speedMps)
		XCTAssertEqual(result, speed)
		
		let testUnit = metric ? "km/h" : "mph"
		let unit = AGDataType.speed.displayedDimension.symbol
		XCTAssertEqual(unit, testUnit)
	}
	
	
	
}
