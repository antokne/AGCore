//
//  AGAverageCurveTests.swift
//  
//
//  Created by Antony Gardiner on 19/05/23.
//

import XCTest
@testable import AGCore

final class AGAverageCurveTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testAvreageCurve() throws {
		
		
		// 3 hour interval
		let activityDuration = 60 * 60 * 3
		let avgCurve = AGAverageCurve(totalActivityTimeS: activityDuration)
		
		let avgValue1 = 1000
		let avgValue2 = 950
		let avgValue3 = 900
		let avgValue4 = 850
		let avgValue5 = 800
		let avgValue10 = 700
		let avgValue15 = 600
		let avgValue20 = 500
		let avgValue25 = 400
		let avgValue30 = 450
		let avgValue60 = 400
		let avgValue120 = 390
		let avgValue180 = 380
		let avgValue240 = 370
		let avgValue300 = 360
		let avgValue360 = 350
		let avgValue420 = 340
		let avgValue480 = 330
		let avgValue540 = 320
		let avgValue600 = 310

		avgCurve.add(value: avgValue1)
		avgCurve.add(value: avgValue2)
		avgCurve.add(value: avgValue3)
		avgCurve.add(value: avgValue4)
		
		for _ in 0..<5 {
			avgCurve.add(value: avgValue5)
		}
		
		for _ in 0..<5 {
			avgCurve.add(value: avgValue10)
		}

		for _ in 0..<5 {
			avgCurve.add(value: avgValue15)
		}

		for _ in 0..<5 {
			avgCurve.add(value: avgValue20)
		}

		for _ in 0..<5 {
			avgCurve.add(value: avgValue25)
		}

		for _ in 0..<5 {
			avgCurve.add(value: avgValue30)
		}

		for _ in 0..<30 {
			avgCurve.add(value: avgValue60)
		}
		
		for _ in 0..<60 {
			avgCurve.add(value: avgValue120)
		}
		
		for _ in 0..<60 {
			avgCurve.add(value: avgValue180)
		}
		for _ in 0..<60 {
			avgCurve.add(value: avgValue240)
		}
		for _ in 0..<60 {
			avgCurve.add(value: avgValue300)
		}
		for _ in 0..<60 {
			avgCurve.add(value: avgValue360)
		}
		for _ in 0..<60 {
			avgCurve.add(value: avgValue420)
		}
		for _ in 0..<60 {
			avgCurve.add(value: avgValue480)
		}
		for _ in 0..<60 {
			avgCurve.add(value: avgValue540)
		}
		for _ in 0..<60 {
			avgCurve.add(value: avgValue600)
		}
		
		for _ in 0..<3600 {
			let avgValue1200 = 290
			avgCurve.add(value: avgValue1200)
		}
		for _ in 0..<3600 {
			let avgValue1800 = 260
			avgCurve.add(value: avgValue1800)
		}
		for _ in 0..<3600 {
			let avgValue2400 = 250
			avgCurve.add(value: avgValue2400)
		}
		for _ in 0..<3600 {
			let avgValue3000 = 240
			avgCurve.add(value: avgValue3000)
		}
		for _ in 0..<3600 {
			let avgValue3600 = 220
			avgCurve.add(value: avgValue3600)
		}
		for _ in 0..<3600 {
			let avgValue7200 = 210
			avgCurve.add(value: avgValue7200)
		}
		for _ in 0..<3600 {
			let avgValue10800 = 200
			avgCurve.add(value: avgValue10800)
		}
		
		for point in avgCurve.points {
			XCTAssertEqual(point.seconds, point.values.count)
		}

		XCTAssertEqual(avgCurve.points.count, 27)
		
		let averages = avgCurve.points.map { $0.getAverage() }
		
		XCTAssertEqual(averages[0], 1000)
		XCTAssertEqual(averages[1], 975)
		XCTAssertEqual(averages[2], 950)
		XCTAssertEqual(averages[3], 925)
		XCTAssertEqual(averages[4], 900)
		XCTAssertEqual(averages[5], 840)
		XCTAssertEqual(averages[6], 786.6666666666666)
		XCTAssertEqual(averages[7], 735)
		XCTAssertEqual(averages[8], 684)
		XCTAssertEqual(averages[9], 638.3333333333334)
		XCTAssertEqual(averages[10], 522.5)
		XCTAssertEqual(averages[11], 456.5833333333333)
		XCTAssertEqual(averages[12], 431.27777777777777)
		XCTAssertEqual(averages[13], 416.125)
		XCTAssertEqual(averages[14], 405.03333333333336)
		XCTAssertEqual(averages[15], 395.97222222222223)
		XCTAssertEqual(averages[16], 388.07142857142856)
		XCTAssertEqual(averages[17], 380.8958333333333)
		XCTAssertEqual(averages[18], 374.2037037037037)
		XCTAssertEqual(averages[19], 367.85)
		XCTAssertEqual(averages[20], 328.9916666666667)
		XCTAssertEqual(averages[21], 315.99444444444447)
		XCTAssertEqual(averages[22], 309.49583333333334)
		XCTAssertEqual(averages[23], 305.5966666666667)
		XCTAssertEqual(averages[24], 302.9972222222222)
		XCTAssertEqual(averages[25], 284.0152777777778)
		XCTAssertEqual(averages[26], 273.2361111111111)
	}
	
	
	
}
