//
//  String+ExtensionTests.swift
//  
//
//  Created by Ant Gardiner on 16/08/23.
//

import XCTest
@testable import AGCore

final class String_ExtensionTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testSplit() throws {
		let string = "ci_session=gugse5htiis3plt79tdvbri3a685e0eb; expires=Fri, 23-Jun-2023 03:02:42 GMT; Max-Age=7200; path=/; domain=.mybiketraffic.com; secure; HttpOnly"
		
		let dict = string.dictionary(with: ";", keyValueSeparator: "=")
		print(dict)
		
		XCTAssertEqual(dict["Max-Age"], "7200")
		XCTAssertEqual(dict["domain"], ".mybiketraffic.com")
		XCTAssertEqual(dict["ci_session"], "gugse5htiis3plt79tdvbri3a685e0eb")

	}
	
	
	
}
