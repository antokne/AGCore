//
//  AGInstantDataTypeTests.swift
//  
//
//  Created by Ant Gardiner on 13/07/23.
//

import XCTest
@testable import AGCore

final class AGInstantDataTypeTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testInstantDataStale() throws {
		
		let instantData = AGInstantDataType(value: 3, date: Date())
		
		XCTAssertFalse(instantData.stale)
		sleep(4)
		XCTAssertFalse(instantData.stale)
		sleep(1)
		XCTAssertTrue(instantData.stale)
		
		
	}
	
	
	
}
