//
//  AGAccumulator.swift
//  
//
//  Created by Antony Gardiner on 1/03/23.
//

import Foundation

public enum AGAccumulatorEvent {
	case pause
	case resume
}

private struct AGAccumulatorPausedData {
	var paused: Bool = false
	var pausedTimeS: Double = 0

	var pausedStartTimeInterval: TimeInterval?

	mutating func pause(timeInterval: TimeInterval) {

		guard !paused else {
			return // can't get a paused message when already paused
		}
		paused = true

		pausedStartTimeInterval = timeInterval
	}

	mutating func resume(timeInterval: TimeInterval) {

		guard paused else {
			return // can't get a resume message when not paused
		}
		paused = false

		if let pausedStartTimeInterval,
		 pausedStartTimeInterval < timeInterval {
			pausedTimeS += (timeInterval - pausedStartTimeInterval)
		}
		pausedStartTimeInterval = nil
	}
}

// Have not decided if this should be a protocol or a class...
open class AGAccumulator {
	
	
	// key value pair of data types that we are acumuating data for...
	private(set) public var accumulatedDataTypes: [AGDataType: AGAverage] = [:]

	private(set) public var startTimeInterval: TimeInterval? = nil
	
	private var pausedData: AGAccumulatorPausedData = AGAccumulatorPausedData()
		
	public init() {
		
	}
	
	// an accumulator gets instant values from somewhere and accumulates them into various things

	
	/// Accumulate this data type, starttime interval is set to the first time interval accumulated.
	/// - Parameters:
	///   - timeInterval: time interval of instant value.
	///   - value: the value of this data type
	///   - type: the data type to accumulate
	public func accumulate(timeInterval: TimeInterval, value: Double, type: AGDataType) {
		
		if accumulatedDataTypes[type] == nil {
			accumulatedDataTypes[type] = AGAverage(type: type)
		}
		
		if startTimeInterval == nil {
			startTimeInterval = timeInterval
		}
		
		if let startTimeInterval {
			let seconds = Double(timeInterval - pausedData.pausedTimeS - startTimeInterval)
			accumulatedDataTypes[type]?.add(x: seconds, y: value)
			
//			print("x: \(seconds) : add value \(value) for type \(type)")
		}
		
	}
	
	public func event(event: AGAccumulatorEvent, at timeInterval: TimeInterval) {
		switch event {
		case .pause:
			pausedData.pause(timeInterval: timeInterval)
		case .resume:
			pausedData.resume(timeInterval: timeInterval)
		}
	}
	
	/// Indicate a lap has occurred
	/// Save the current accumulated data ready to generate new accumulations
	public func lap() {
		
	}
	
	/// Indicates a session has ended, e.g. change from swim to t1 in a multisport workout.
	public func endSession() {
		
	}
}
