//
//  Data+AsHexTests.swift
//  
//
//  Created by Ant Gardiner on 10/08/23.
//

import XCTest
@testable import AGCore

final class Data_AsHexTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testAsHex() throws {
		
		// Given
		let data = Data([1,2,3,4,5,6,7,8,9,10,11,12,13,14,238])
		
		// When
		let hexString = data.hexEncodedString(options: [.upperCase])
		
		// Then
		XCTAssertEqual(hexString, "0102030405060708090A0B0C0D0EEE")
		
		// When
		let convertedData = hexString.asData()
		
		// Then
		XCTAssertEqual(data, convertedData)
		
	}
	
	
	
}
