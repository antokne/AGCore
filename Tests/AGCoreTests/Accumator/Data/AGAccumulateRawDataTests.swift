//
//  AGAccumulateRawDataTests.swift
//  
//
//  Created by Ant Gardiner on 5/07/23.
//

import XCTest
@testable import AGCore

final class AGAccumulateRawDataTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testSerialiseAndLoadRawData() async throws {
	
		var rawData = AGAccumulatorRawData()
		
		// add some data.
		rawData.add(value: AGDataTypeValue(type: .distance, value: 1), second: 1)
		rawData.add(value: AGDataTypeValue(type: .altitude, value: 1), second: 1)
		rawData.add(value: AGDataTypeValue(type: .speed, value: 3), second: 1)
		rawData.add(arrayValue: AGDataTypeArrayValue(type: .radarRanges, values: [1,2,3,4]), second: 1)
		rawData.add(value: AGDataTypeValue(type: .distance, value: 1), second: 2)
		rawData.add(value: AGDataTypeValue(type: .altitude, value: 1), second: 2)
		rawData.add(value: AGDataTypeValue(type: .speed, value: 3), second: 2)
		rawData.add(arrayValue: AGDataTypeArrayValue(type: .radarRanges, values: [1,2,3,4]), second: 2)

		// cache to file
		try rawData.cache(to: AGFileManager.documentsURL)
		
		// Check 1
		// load file
		var loadedData = try await AGAccumulatorRawData.load(from: AGFileManager.documentsURL) { progress in
			
		}
		
		// should contain just the above data.
		XCTAssertEqual(2, loadedData.maxSecond)
		XCTAssertEqual(2, loadedData.data.count)
		XCTAssertEqual(2, loadedData.arrayData.count)
		
		// add some more data
		rawData.add(value: AGDataTypeValue(type: .distance, value: 1), second: 3)
		rawData.add(value: AGDataTypeValue(type: .altitude, value: 1), second: 3)
		rawData.add(value: AGDataTypeValue(type: .speed, value: 3), second: 3)
		rawData.add(arrayValue: AGDataTypeArrayValue(type: .radarRanges, values: [1,2,3,4]), second: 3)
		rawData.add(value: AGDataTypeValue(type: .distance, value: 1), second: 4)
		rawData.add(value: AGDataTypeValue(type: .altitude, value: 1), second: 4)
		rawData.add(value: AGDataTypeValue(type: .speed, value: 3), second: 4)
		rawData.add(arrayValue: AGDataTypeArrayValue(type: .radarRanges, values: [1,2,3,4]), second: 4)

		// cache to file (should just append new stuff
		try rawData.cache(to: AGFileManager.documentsURL)

		// check.
		XCTAssertEqual(4, rawData.maxSecond)
		XCTAssertEqual(4, rawData.data.count)
		XCTAssertEqual(4, rawData.arrayData.count)

	
		// load file 2
		loadedData = try await AGAccumulatorRawData.load(from: AGFileManager.documentsURL) { progress in
			
		}
		
		// should contain what we had after last data was added.
		XCTAssertEqual(4, loadedData.maxSecond)
		XCTAssertEqual(4, loadedData.data.count)
		XCTAssertEqual(4, loadedData.arrayData.count)
	}
	
	
}
