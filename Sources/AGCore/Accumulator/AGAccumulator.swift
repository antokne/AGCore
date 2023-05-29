//
//  AGAccumulator.swift
//  
//
//  Created by Antony Gardiner on 1/03/23.
//

import Foundation

public enum AGAccumulatorEvent {
	case start
	case stop
	case pause
	case resume
	case lap
	case session
}

public enum AGAccumlatorSportType {
	case roadCycling
	case gravelCylcing
	case mtb
}

public enum AGAccumulatorState {
	case stopped
	case running
	case paused
	
	func isRunning() -> Bool {
		self == .running || self == .paused
	}
}

public enum AGAccumlatorError: Error {
	case notRunning
	case running
}

internal struct AGAccumulatorPausedData {
	var paused: Bool = false
	var pausedTimeS: Double = 0

	var pausedStartTimeInterval: TimeInterval?

	@discardableResult
	mutating func pause(timeInterval: TimeInterval) -> Bool {

		guard !paused else {
			return false // can't get a paused message when already paused
		}
		paused = true

		pausedStartTimeInterval = timeInterval
		return true
	}

	@discardableResult
	mutating func resume(timeInterval: TimeInterval) -> Bool {

		guard paused else {
			return false// can't get a resume message when not paused
		}
		paused = false

		if let pausedStartTimeInterval,
		 pausedStartTimeInterval < timeInterval {
			pausedTimeS += (timeInterval - pausedStartTimeInterval)
		}
		pausedStartTimeInterval = nil
		return true
	}
}

public struct AGAccumulatorData {
	private(set) public var data: [AGDataType: AGAverage] = [:]
	
	fileprivate(set) public var sport: AGAccumlatorSportType = .roadCycling
	
	public mutating func add(type: AGDataType, seconds: TimeInterval, value: Double) {
		
		if data[type] == nil {
			data[type] = AGAverage(type: type)
		}
		
		data[type]?.add(x: seconds, y: value)
	}
	
}

// Can be used for mutliple lap and session data.
public struct AGAccumlatorMultiData {
	
	private(set) public var previousData: [AGAccumulatorData] = []
	
	private(set) public var currentData: AGAccumulatorData = AGAccumulatorData()

	public init() {
		
	}
	
	mutating func add(type: AGDataType, seconds: TimeInterval, value: Double) {
		currentData.add(type: type, seconds: seconds, value: value)
	}
	
	/// End current data collection, add to previous data and create a new current.
	mutating func rollCurrent() {
		previousData.append(currentData)
		currentData = AGAccumulatorData()
	}

}

// Have not decided if this should be a protocol or a class...
open class AGAccumulator {
	
	var state: AGAccumulatorState = .stopped
	
	/// key value pair of data types that we are acumuating data for.
	private(set) public var sessionData: AGAccumlatorMultiData = AGAccumlatorMultiData()
	private(set) public var lapData: AGAccumlatorMultiData = AGAccumlatorMultiData()
	
	/// Time activity recording started
	private(set) public var startDate: Date? = nil
	
	private var pausedData: AGAccumulatorPausedData = AGAccumulatorPausedData()
		
	public init() {
		
	}
	
	// an accumulator gets instant values from somewhere and accumulates them into various things

	
	/// Accumulate this data type, starttime interval is set to the first time interval accumulated.
	/// - Parameters:
	///   - date: timestamp this data value is for.
	///   - value: the value of this data type
	///   - type: the data type to accumulate
	public func accumulate(date: Date, value: Double, type: AGDataType) throws {
		
		guard state.isRunning() else {
			throw AGAccumlatorError.notRunning
		}

		guard pausedData.paused == false else {
			return
		}

		guard let startDate else {
			throw AGAccumlatorError.notRunning
		}
		
		let seconds = timeInterval(for: date, since: startDate)
		lapData.add(type: type, seconds: seconds, value: value)
		sessionData.add(type: type, seconds: seconds, value: value)

//		print("x: \(seconds) : add value \(value) for type \(type)")
		
	}
	
	public func event(event: AGAccumulatorEvent, at date: Date) {

		switch event {
		case .pause:
			pause(date: date)
		case .resume:
			resume(date: date)
		case .start:
			start(startDate: date)
		case .stop:
			stop()
		case .lap:
			lap()
		case .session:
			endSession()
		}
	}
	
	private func start(startDate: Date) {
		guard state == .stopped else {
			return
		}
		self.startDate = startDate
		state = .running
	}
	
	private func pause(date: Date) {
		
		guard state.isRunning() else {
			return
		}

		guard let startDate else {
			return
		}
		let timeInterval = timeInterval(for: date, since: startDate)

		if pausedData.pause(timeInterval: timeInterval) {
			state = .paused
		}
	}
	
	private func resume(date: Date) {
		guard state.isRunning() else {
			return
		}
		
		guard let startDate else {
			return
		}
		let timeInterval = timeInterval(for: date, since: startDate)
		
		if pausedData.resume(timeInterval: timeInterval) {
			state = .running
		}
	}
	
	private func stop() {
		if state.isRunning() {
			state = .stopped
		}
	}
	
	/// Indicate a lap has occurred
	/// Save the current accumulated data ready to generate new accumulations
	private  func lap() {
		lapData.rollCurrent()
	}
	
	/// Indicates a session has ended, e.g. change from swim to t1 in a multisport workout.
	private  func endSession() {
		lapData.rollCurrent()
		sessionData.rollCurrent()
	}
	
	private func timeInterval(for date: Date, since startDate: Date) -> TimeInterval {
		date.timeIntervalSince(startDate)
	}
}
