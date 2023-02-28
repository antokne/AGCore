//
//  AGZonesCalculatorTests.swift
//  
//
//  Created by Antony Gardiner on 27/02/23.
//

import XCTest
@testable import AGCore

final class AGZonesCalculatorTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testZones() {
		
		let zonesCalculator = AGZonesCalculator()
		
		zonesCalculator.addZone(type: .heartrate, hiLimit: 108)
		zonesCalculator.addZone(type: .heartrate, hiLimit: 138)
		zonesCalculator.addZone(type: .heartrate, hiLimit: 254)
		zonesCalculator.addZone(type: .heartrate, hiLimit: 126)
		zonesCalculator.addZone(type: .heartrate, hiLimit: 158)
		
		guard let allHRZones = zonesCalculator.allZoneTypes[.heartrate] else {
			XCTFail("No HR ZONES")
			return
		}
		
		XCTAssertEqual(allHRZones.count, 5)
		
		for (index, zoneType) in allHRZones.enumerated() {
			XCTAssertEqual(zoneType.zone.type, .heartrate)

			switch index {
			case 0:
				XCTAssertEqual(zoneType.zone.hiLimit, 108)
			case 1:
				XCTAssertEqual(zoneType.zone.hiLimit, 126)
			case 2:
				XCTAssertEqual(zoneType.zone.hiLimit, 138)
			case 3:
				XCTAssertEqual(zoneType.zone.hiLimit, 158)
			case 4:
				XCTAssertEqual(zoneType.zone.hiLimit, 254)
			default:
				break
			}
		}
		
		
		zonesCalculator.addZone(type: .power, hiLimit: 65534)
		zonesCalculator.addZone(type: .power, hiLimit: 281)
		zonesCalculator.addZone(type: .power, hiLimit: 207)
		zonesCalculator.addZone(type: .power, hiLimit: 447)
		zonesCalculator.addZone(type: .power, hiLimit: 336)
		zonesCalculator.addZone(type: .power, hiLimit: 392)
		
		guard let allPowerZones = zonesCalculator.allZoneTypes[.power] else {
			XCTFail("No POWER ZONES")
			return
		}
		
		XCTAssertEqual(allPowerZones.count, 6)

		
		for (index, zoneType) in allPowerZones.enumerated() {
			XCTAssertEqual(zoneType.zone.type, .power)
			
			switch index {
			case 0:
				XCTAssertEqual(zoneType.zone.hiLimit, 207)
			case 1:
				XCTAssertEqual(zoneType.zone.hiLimit, 281)
			case 2:
				XCTAssertEqual(zoneType.zone.hiLimit, 336)
			case 3:
				XCTAssertEqual(zoneType.zone.hiLimit, 392)
			case 4:
				XCTAssertEqual(zoneType.zone.hiLimit, 447)
			case 5:
				XCTAssertEqual(zoneType.zone.hiLimit, 65534)
			default:
				break
			}
		}
		
		
		// add some values
		zonesCalculator.add(type: .heartrate, instantValue: 100, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 125, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 127, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 157, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 210, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 100, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 125, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 127, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 157, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 210, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 100, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 125, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 127, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 157, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 210, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 100, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 125, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 127, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 157, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 210, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 100, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 125, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 127, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 157, timeDeltaS: 1)
		zonesCalculator.add(type: .heartrate, instantValue: 210, timeDeltaS: 1)
		
		for zoneType in allHRZones {
			XCTAssertEqual(zoneType.timeInZoneS, 5)
		}
		
		zonesCalculator.add(type: .power, instantValue: 108, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 207, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 281, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 391, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 392, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 448, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 108, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 207, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 281, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 391, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 392, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 448, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 108, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 207, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 281, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 391, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 392, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 448, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 108, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 207, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 281, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 391, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 392, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 448, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 108, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 207, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 281, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 391, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 392, timeDeltaS: 1)
		zonesCalculator.add(type: .power, instantValue: 448, timeDeltaS: 1)
		
		for zoneType in allPowerZones {
			XCTAssertEqual(zoneType.timeInZoneS, 5)
		}
	}
}
