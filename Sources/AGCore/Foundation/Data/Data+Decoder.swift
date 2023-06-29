//
//  Data+Decoder.swift
//  
//
//  Created by Antony Gardiner on 28/06/23.
//

import Foundation

public extension Data {
	
	/// Decode using convert from snake case
	/// - Returns: a deoced object or throws an exception.
	func decodeData<T: Codable>() throws -> T {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return try decoder.decode(T.self, from: self)
	}
	
}
