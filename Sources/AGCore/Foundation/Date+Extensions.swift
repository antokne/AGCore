//
//  Date+Extensions.swift
//  RaceWeight
//
//  Created by Antony Gardiner on 16/12/22.
//

import Foundation

extension Date {
	public var startOfWeek: Date? {
		let gregorian = Calendar(identifier: .gregorian)
		guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
		else {
			return nil
		}
		return gregorian.date(byAdding: .day, value: 1, to: sunday)
	}
}
