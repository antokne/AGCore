//
//  AGAccumulatorMultiData.swift
//  
//
//  Created by Antony Gardiner on 30/05/23.
//

import Foundation

// Can be used for mutliple lap and session data.
public struct AGAccumulatorMultiData {
	
	private(set) public var previousData: [AGAccumulatorData] = []
	
	private(set) public var currentData: AGAccumulatorData = AGAccumulatorData()
	
	public init() {
		
	}
	
	mutating func start(startDate: Date) {
		previousData = []
		currentData = AGAccumulatorData(startDate: startDate)
	}
	
	mutating func add(type: AGDataType, date: Date, value: Double) {
		currentData.add(type: type, date: date, value: value)
	}
	
	/// End current data collection, add to previous data and create a new current.
	mutating func rollCurrent(date: Date) {
		previousData.append(currentData)
		currentData = AGAccumulatorData(startDate: date)
	}
	
	mutating func pause(date: Date) -> Bool {
		currentData.pause(date: date)
	}
	
	mutating func resume(date: Date) -> Bool {
		currentData.resume(date: date)
	}
	
	mutating func updateWorkoutTime(date: Date) {
		currentData.updateWorkoutTime(date: date)
	}
}
