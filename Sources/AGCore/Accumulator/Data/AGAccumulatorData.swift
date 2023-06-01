//
//  AGAccumulatorData.swift
//  
//
//  Created by Antony Gardiner on 30/05/23.
//

import Foundation

internal func timeInterval(for date: Date, since startDate: Date) -> TimeInterval {
	date.timeIntervalSince(startDate)
}

/// Accumulation of an individual session or lap
public struct AGAccumulatorData {
	private(set) public var data: [AGDataType: AGAverage] = [:]
	private(set) public var sport: AGAccumlatorSportType
	private(set) public var startDate: Date
	private(set) public var durationS: TimeInterval = 0

	/// Paused data for this session or lap.
	private var pausedData: AGAccumulatorPausedData = AGAccumulatorPausedData()
	
	public var pausedTimeS: TimeInterval {
		pausedData.pausedTimeS
	}
	
	public var totalTimeS: TimeInterval {
		durationS + pausedTimeS
	}
	
	init(sport: AGAccumlatorSportType = .roadCycling , startDate: Date = Date()) {
		self.sport = sport
		self.startDate = startDate
		self.durationS = 0
		data[.startTime] = AGAverage(type: .startTime)
		data[.startTime]?.add(x: 0, y: startDate.timeIntervalSinceReferenceDate)
		
	}
	
	public func value(for type: AGDataType, avgType: AGAverageType) -> Double? {
		data[type]?.getValue(for: avgType)
	}
	
	public mutating func add(type: AGDataType, date: Date, value: Double) {
		
		if data[type] == nil {
			data[type] = AGAverage(type: type)
		}
		
		if pausedData.paused {
			return
		}
		
		let seconds = timeInterval(for: date, since: startDate)
		
		data[type]?.add(x: seconds, y: value)
		
		if seconds > durationS {
			updateDuration(seconds: seconds)
		}
	}
	
	private mutating func updateDuration(seconds: TimeInterval) {
		durationS = seconds - pausedData.pausedTimeS
		if data[.timestamp] == nil {
			data[.timestamp] = AGAverage(type: .timestamp)
			data[.workoutTime] = AGAverage(type: .workoutTime)
		}
		let durationDate = startDate.addingTimeInterval(durationS)
		data[.timestamp]?.add(x: seconds, y: durationDate.timeIntervalSinceReferenceDate)
		data[.workoutTime]?.add(x: seconds, y: durationS)
	}
	
	mutating func pause(date: Date) -> Bool {
		let timeInterval = timeInterval(for: date, since: startDate)
		if pausedData.pause(timeInterval: timeInterval) {
			return true
		}
		return false
	}
	
	mutating func resume(date: Date) -> Bool {
		let timeInterval = timeInterval(for: date, since: startDate)
		if pausedData.resume(timeInterval: timeInterval) {
			return true
		}
		return false
	}
	
	mutating func updateWorkoutTime(date: Date) {
		if pausedData.paused == false {
			add(type: .workoutTime, date: date, value: durationS)
		}
	}
}
