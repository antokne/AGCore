//
//  Date+Extensions.swift
//  RaceWeight
//
//  Created by Antony Gardiner on 16/12/22.
//

import Foundation

public extension Date {
	var startOfWeek: Date? {
		let gregorian = Calendar.current
		guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
		else {
			return nil
		}
		
		return sunday
	}
	
	/// Add n second to date.
	/// - Parameter seconds: to add
	/// - Returns: new date with seconds added
	func plus(_ seconds: TimeInterval) -> Date {
		self + seconds
	}
	
	/// A reminder that this is a plain old date with no time zone information attached.
	static var gmt: Date {
		Date()
	}
}
