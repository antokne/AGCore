//
//  SimpleHTTPServiceTests.swift
//  
//
//  Created by Ant Gardiner on 21/07/23.
//

import XCTest
@testable import AGCore

final class SimpleHTTPServiceTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testSimpleHTTPAuthAddNoUpload() throws {
		
		// Does not exist in Keychain
		var service = SimpleHTTPAuth(service: "test-service")
		XCTAssertNil(service)
		
		service = SimpleHTTPAuth(service: "test-service", email: "ant@gard.com", password: "1245$*&Gfg^")
		XCTAssertNotNil(service)
		XCTAssertEqual(service?.service, "test-service")
		XCTAssertEqual(service?.email, "ant@gard.com")
		XCTAssertEqual(service?.password, "1245$*&Gfg^")

		
		// test json encoding/decoding
		
		let data = try JSONEncoder().encode(service)
		XCTAssertNotNil(data)
		
		let item = try JSONDecoder().decode(SimpleHTTPAuth.self, from: data)
		XCTAssertNotNil(item)
		XCTAssertEqual(item.service, "test-service")
		XCTAssertEqual(item.email, "ant@gard.com")
		XCTAssertEqual(item.password, "1245$*&Gfg^")
	}
	
	func testSimpleHTTPAuthAddUpload() throws {
		
		// Does not exist in Keychain
		var service = SimpleHTTPAuth(service: "test-service")
		XCTAssertNil(service)
		
		service = SimpleHTTPAuth(service: "test-service", email: "ant@gard.com", password: "1245$*&Gfg^")
		XCTAssertNotNil(service)
		XCTAssertEqual(service?.service, "test-service")
		XCTAssertEqual(service?.email, "ant@gard.com")
		XCTAssertEqual(service?.password, "1245$*&Gfg^")
		XCTAssertTrue(service?.automaticUpload ?? false)
		
		service?.automaticUpload = false
		
		// test json encoding/decoding
		
		let data = try JSONEncoder().encode(service)
		XCTAssertNotNil(data)
		
		let item = try JSONDecoder().decode(SimpleHTTPAuth.self, from: data)
		XCTAssertNotNil(item)
		XCTAssertEqual(item.service, "test-service")
		XCTAssertEqual(item.email, "ant@gard.com")
		XCTAssertEqual(item.password, "1245$*&Gfg^")
		XCTAssertFalse(item.automaticUpload ?? true)

	}
}
