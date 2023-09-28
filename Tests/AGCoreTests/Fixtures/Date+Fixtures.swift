//
//  Date+Fixtures.swift
//
//
//  Created by Ant Gardiner on 21/09/23.
//

import Foundation


extension Date {
	
	
}

extension DateFormatter {
	
	static func RFC3339DateFormatter(timeZone: TimeZone = TimeZone.current) -> DateFormatter {
		let RFC3339DateFormatter = DateFormatter()
		RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
		RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		RFC3339DateFormatter.timeZone = timeZone
		return RFC3339DateFormatter
	}
}
