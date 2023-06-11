//
//  AGUserDefaultsTests.swift
//  
//
//  Created by Antony Gardiner on 12/06/23.
//

import XCTest
@testable import AGCore

final class AGUserDefaultsTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testStoreDefaults() throws {

		@AGUserDefaultStringValue(keyName: "activity-folder", defaultValue: "activities") var defaultSubFolder: String
		
		XCTAssertEqual(defaultSubFolder, "activities")
		
		defaultSubFolder = "documents"
		
		@AGUserDefaultStringValue(keyName: "activity-folder", defaultValue: "activities") var anotherDefaultSubFolder: String
		
		XCTAssertEqual(defaultSubFolder, anotherDefaultSubFolder)
		XCTAssertEqual(anotherDefaultSubFolder, "documents")
		
		_defaultSubFolder.delete()
	}
	
	
}
