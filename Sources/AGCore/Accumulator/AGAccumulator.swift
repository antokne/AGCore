//
//  AGAccumulator.swift
//  
//
//  Created by Antony Gardiner on 1/03/23.
//

import Foundation

public enum AGAccumulatorEvent {

	/// start a recording from stoped state.
	case start
	
	/// Stop the current recording can be either running or paused
	case stop
	
	/// from activiely recording, pause.
	case pause
	
	/// resume from being paused.
	case resume
	
	/// End current and create a new one
	case lap
	
	/// rollover the current session and create a new one
	case session

	/// Run the polling task
	case poll
	
	/// reset all data collected. only allowed if stopped.
	case reset
}

public enum AGAccumlatorSportType {
	case roadCycling
	case gravelCylcing
	case mtb
}

public enum AGAccumulatorState {
	
	/// not recording an activity
	case stopped
	
	/// actively recording and summarising data for activity
	case running
	
	/// recording is pause, no data is summarised.
	case paused
	
	func isRunning() -> Bool {
		self == .running || self == .paused
	}
	
	func paused() -> Bool {
		self == .paused
	}
}

public enum AGAccumlatorError: Error {
	case notRunning
	case running
}

// Have not decided if this should be a protocol or a class...
open class AGAccumulator {
	
	private(set) public var state: AGAccumulatorState = .stopped
	
	private(set) public var instantData: [AGDataType: Double] = [:]
	
	/// key value pair of data types that we are acumuating data for.
	private(set) public var sessionData: AGAccumulatorMultiData = AGAccumulatorMultiData()
	private(set) public var lapData: AGAccumulatorMultiData = AGAccumulatorMultiData()
	
	private(set) public var rawData: AGAccumulatorRawData = AGAccumulatorRawData()
	
	/// Time activity recording started
	private(set) public var startDate: Date? = nil
			
	public init() {
		
	}
	
	// an accumulator gets instant values from somewhere and accumulates them into various things

	public func add(instant value: Double, type: AGDataType) {
		instantData[type] = value
	}
	
	/// Accumulate this data type, starttime interval is set to the first time interval accumulated.
	/// - Parameters:
	///   - date: timestamp this data value is for.
	///   - value: the value of this data type
	///   - type: the data type to accumulate
	public func accumulate(date: Date, value: Double, type: AGDataType) throws {
		
		guard state.isRunning() else {
			throw AGAccumlatorError.notRunning
		}

		guard let startDate else {
			throw AGAccumlatorError.notRunning
		}
		
		lapData.add(type: type, date: date, value: value)
		sessionData.add(type: type, date: date, value: value)
		
		// Add to raw data, this enables us to recreate whatever we want.
		let seconds = Int(timeInterval(for: date, since: startDate))
		rawData.add(value: AGDataTypeValue(type: type, value: value), second: seconds, paused: state.paused())
	}
	
	public func accumulate(date: Date, arrayValue: AGDataTypeArrayValue) throws {
		
		guard let startDate else {
			throw AGAccumlatorError.notRunning
		}
		
		let seconds = Int(timeInterval(for: date, since: startDate))
		rawData.add(arrayValue: arrayValue, second: seconds, paused: state.paused())
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
			lap(date: date)
		case .session:
			endSession(date: date)
		case .poll:
			poll(date: date)
		case .reset:
			reset()
		}
	}
	
	private func start(startDate: Date) {
		guard state == .stopped else {
			return
		}
		self.startDate = startDate
		self.lapData.start(startDate: startDate)
		self.sessionData.start(startDate: startDate)
		state = .running
	}
	
	private func pause(date: Date) {
		
		guard state.isRunning() else {
			return
		}
		if sessionData.pause(date: date) && lapData.pause(date: date) {
			state = .paused
		}
	}
	
	private func resume(date: Date) {
		guard state.isRunning() else {
			return
		}
		if sessionData.resume(date: date) && lapData.resume(date: date) {
			state = .running
		}
	}
	
	private func stop() {
		if state.isRunning() {
			state = .stopped
		}
	}
	
	private func reset() {
		if state == .stopped {
			sessionData = AGAccumulatorMultiData()
			lapData = AGAccumulatorMultiData()
			rawData = AGAccumulatorRawData()
			startDate = nil
		}
	}
	
	private func poll(date: Date) {
		if state.isRunning() {
			sessionData.updateWorkoutTime(date: date)
			lapData.updateWorkoutTime(date: date)
		}
	}
	
	/// Indicate a lap has occurred
	/// Save the current accumulated data ready to generate new accumulations
	private  func lap(date: Date) {
		lapData.rollCurrent(date: date)
	}
	
	/// Indicates a session has ended, e.g. change from swim to t1 in a multisport workout.
	private  func endSession(date: Date) {
		lapData.rollCurrent(date: date)
		sessionData.rollCurrent(date: date)
	}
}
