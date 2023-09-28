//
//  Calendar+Extensions.swift
//
//
//  Created by Ant Gardiner on 21/09/23.
//

import Foundation


public extension Calendar {
	
	// case 1
	func dateBySetting(timeZone: TimeZone, of date: Date) -> Date? {
		var components = dateComponents(in: self.timeZone, from: date)
		components.timeZone = timeZone
		return self.date(from: components)
	}
	
	/// Generates a date using current calendar timezone and converts to dest timezone
	/// - Parameters:
	///   - timeZone: the destination time zone
	///   - date: the date to convert
	/// - Returns: the converted date if ok.
	func dateBySettingTimeFrom(timeZone: TimeZone, of date: Date) -> Date? {
		var components = dateComponents(in: timeZone, from: date)
		components.timeZone = self.timeZone
		return self.date(from: components)
	}
	
	/// Returns a Calendar set with the gmt timezone.
	static var gmt: Calendar = {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = .gmt
		return calendar
	}()
}
