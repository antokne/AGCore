//
//  MyBikeTrafficStructs.swift
//  
//
//  Created by Antony Gardiner on 28/06/23.
//

import Foundation

/// Contains details of the ride on MyBikeTraffic.com
public struct MyBikeTrafficRide: Codable {
	
	/// maps to user_id returned from an upload
	var userId: String
	
	/// maps to the id of the ride uploaded, can use in a link.
	var id: Int
	
	/// number of moving cars detected in the ride.
	var movingcars: Int?
}

/// Response object returned from an upload
public struct MyBikeTrafficUploadResponse: Codable {
	
	/// Name of the file uploaded
	var name: String?
	
	/// ride details on the file uploaded
	var ride: MyBikeTrafficRide?
	
	/// optional error string returned when something goes wrong.
	var err: String?
	
	/// If upload already completed for this file, return it's id
	var dup: String?
}
