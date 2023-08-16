//
//  File.swift
//  
//
//  Created by Ant Gardiner on 16/08/23.
//

import Foundation


public extension String {
	
	func dictionary(with itemSeparator: Self.Element, keyValueSeparator: Self.Element) -> [String: String] {
				
		let keyValues = self.split(separator: itemSeparator).reduce(into: [String: String]()) {
		
			let values = $1.split(separator: keyValueSeparator)
			
			if let key = values.first?.trimmingCharacters(in: .whitespaces),
				let value = values.last?.trimmingCharacters(in: .whitespaces) {
				$0[String(key)] = String(value)
			}
			
		}
		return keyValues
	}
	
	func cookieProperties() -> [HTTPCookiePropertyKey: Any] {
		
		var properties: [HTTPCookiePropertyKey: Any] = [: ]
		
		let dict = self.dictionary(with: ";", keyValueSeparator: "=")
		
		for (key, value) in dict {
			
			switch key {
			case "domain":
				properties[.domain] = value
			case "path":
				properties[.path] = value
			case "Max-Age":
				properties[.maximumAge] = value
			case "secure":
				properties[.maximumAge] = true
			case "ci_session":
				properties[.name] = key
				properties[.value] = value
			case "expires":
				properties[.expires] = try? Date(value, strategy: .dateTime)
			default:
				break
			}
		}
		
		
		return properties
	}
	
}
