//
//  MyBikeTrafficTests.swift
//  
//
//  Created by Antony Gardiner on 29/06/23.
//

import XCTest
@testable import AGCore

final class MyBikeTrafficTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	
	
	func testDecoding() throws {
		
		let json = """
		{
		  "name": "2023-06-26-15-19-20.fit",
		  "ride": {
		 "user_id": "5974",
		 "jsonfile": "2023-06-26-15-19-20.fit",
		 "title": "Untitled 2023-06-26 20:19:20",
		 "dist": 20423,
		 "disableddist": 0,
		 "elapsedtime": 5337,
		 "movingtime": 4166,
		 "disabledtime": 0,
		 "totalcars": 0,
		 "movingcars": 72,
		 "datecreated": "2023-06-28 03:28:49",
		 "dateride": "2023-06-26 20:19:20",
		 "tzname": "CDT",
		 "tzoffset": "-21600",
		 "tzdaylight": "3600",
		 "id": 46488
		  },
		  "err": null,
		  "dup": null
		}
		""".data(using: .utf8)!

		let mbtResponse: MyBikeTrafficUploadResponse = try json.decodeData()
		XCTAssertEqual(mbtResponse.name, "2023-06-26-15-19-20.fit")
		let ride = try XCTUnwrap(mbtResponse.ride)
		
		XCTAssertEqual(ride.id, 46488)
		XCTAssertEqual(ride.userId, "5974")

	}
	
	
	func testDecodingDup() throws {
		let json = """
		{
			"name":"2023-06-23-164718-Veloscope.fit",
			"ride":null,
			"err":"Duplicate found",
			"dup":"46627"
		}
		""".data(using: .utf8)!
		
		let mbtResponse: MyBikeTrafficUploadResponse = try json.decodeData()
		XCTAssertEqual(mbtResponse.name, "2023-06-23-164718-Veloscope.fit")
		XCTAssertNil(mbtResponse.ride)
		XCTAssertEqual(mbtResponse.err, "Duplicate found")
		XCTAssertEqual(mbtResponse.dup, "46627")

	}
	
	func testDecodingBadRideType() throws {
		
		let json = """
		{
			"name":"2023-06-23-164718-Veloscope.fit",
			"ride":false,
			"err":"No radar info found",
			"dup":null
		}
		""".data(using: .utf8)!
  
		do {
			let _: MyBikeTrafficUploadResponse = try json.decodeData()
		}
		catch let DecodingError.typeMismatch(type, context) {
			print("\(type) --- \(context.codingPath)")
			
			let jsonObject = try JSONSerialization.jsonObject(with: json) as? [String: Any]
			XCTAssertEqual(jsonObject?["err"] as? String, "No radar info found")
			XCTAssertEqual(jsonObject?["name"] as? String, "2023-06-23-164718-Veloscope.fit")
		}
	
	}
	
}
