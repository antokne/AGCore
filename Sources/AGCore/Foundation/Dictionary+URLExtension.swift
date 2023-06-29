//
//  Dictionary+URLExtension.swift
//  
//
//  Created by Antony Gardiner on 28/06/23.
//

import Foundation

protocol URLQueryParameterStringConvertible {
	var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
	/**
	 This computed property returns a query parameters string from the given NSDictionary. For
	 example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
	 string will be @"day=Tuesday&month=January".
	 @return The computed parameters string.
	 */
	var queryParameters: String {
		var parts: [String] = []
		for (key, value) in self {
			let part = String(format: "%@=%@",
							  String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
							  String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
			parts.append(part as String)
		}
		return parts.joined(separator: "&")
	}
	
}
