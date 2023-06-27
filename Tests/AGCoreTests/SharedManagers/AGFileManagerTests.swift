//
//  AGFileManagerTests.swift
//  
//
//  Created by Antony Gardiner on 8/06/23.
//

import XCTest
@testable import AGCore

final class AGFileManagerTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testDocumentsURL() throws {
		
		XCTAssertTrue(AGFileManager.documentsURL.path.hasSuffix("Documents"))
		
	}
	
	func testdocumentsSubDirectory() throws {
		
		var dir = try XCTUnwrap(AGFileManager.documentsSubDirectory(path: "activities", create: false))
		XCTAssertTrue(dir.path.hasSuffix("Documents/activities"))
		
		dir = try XCTUnwrap(AGFileManager.documentsSubDirectory(path: "images", create: false))
		XCTAssertTrue(dir.path.hasSuffix("Documents/images"))
		
		dir = try XCTUnwrap(AGFileManager.documentsSubDirectory(path: "h/f/t/r/g", create: false))
		XCTAssertTrue(dir.path.hasSuffix("Documents/h/f/t/r/g"))
	}
	
}
