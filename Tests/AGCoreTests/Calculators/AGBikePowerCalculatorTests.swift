//
//  AGBikePowerCalculatorTests.swift
//  
//
//  Created by Antony Gardiner on 27/02/23.
//

import XCTest
@testable import AGCore

final class AGBikePowerCalculatorTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testBikePowerCalculator() throws {
		
		let bikePowerCalulator: AGBikePowerCalculator = AGBikePowerCalculator(ftp: 200)

		var sumEnergy = 0
		
		// an hour ride at ftp
		for _ in 0...3600 {
			bikePowerCalulator.addDeltaWork(deltaWork: 200, deltaMs: 1000)
			sumEnergy += 200
		}

		
		print(bikePowerCalulator)
		
		XCTAssertEqual(bikePowerCalulator.normalizedPowerData.ftp, 200)
		XCTAssertEqual(bikePowerCalulator.normalizedPowerData.normalisedPower, 200)
		XCTAssertEqual(bikePowerCalulator.normalizedPowerData.intensityFactor, 1)
		XCTAssertEqual(bikePowerCalulator.normalizedPowerData.trainingStressScore, 100, accuracy: 0.03)
		
		XCTAssertEqual(bikePowerCalulator.normalizedPowerData.energy, Double(sumEnergy))
		

		
		
	}
	
	
}
