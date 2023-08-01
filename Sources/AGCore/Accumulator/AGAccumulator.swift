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

public enum AGAccumlatorSportType: Codable {
	case roadCycling
	case gravelCylcing
	case mtb
}

public enum AGAccumulatorState: Codable {
	
	/// not recording an activity
	case stopped
	
	/// actively recording and summarising data for activity
	case running
	
	/// recording is pause, no data is summarised.
	case paused
	
	func isRunning() -> Bool {
		self == .running || self == .paused
	}
	
	func isPaused() -> Bool {
		self == .paused
	}
}

public enum AGAccumlatorError: Error {
	case notRunning
	case running
}

public typealias InstantDataType = [AGDataType: AGInstantDataType]

// Have not decided if this should be a protocol or a class...
open class AGAccumulator: Codable {
	
	private(set) public var state: AGAccumulatorState = .stopped
	
	private(set) public var instantData: InstantDataType = [:]
	
	/// key value pair of data types that we are acumuating data for.
	private(set) public var sessionData: AGAccumulatorMultiData = AGAccumulatorMultiData()
	private(set) public var lapData: AGAccumulatorMultiData = AGAccumulatorMultiData()
	
	private(set) public var rawData: AGAccumulatorRawData = AGAccumulatorRawData()
	
	/// Time activity recording started
	private(set) public var startDate: Date? = nil
			
	public init() {
		
	}
	
	/// Ignore raw data from Encoding/Decoding
	enum CodingKeys: CodingKey {
		case state, instantData, sessionData, lapData, startDate
	}
	
	/// Decoder init
	/// - Parameter decoder: decoder used
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		state = try container.decode(AGAccumulatorState.self, forKey: .state)
		instantData = try container.decode(InstantDataType.self, forKey: .instantData)
		sessionData = try container.decode(AGAccumulatorMultiData.self, forKey: .sessionData)
		lapData = try container.decode(AGAccumulatorMultiData.self, forKey: .lapData)
		startDate = try container.decode(Date.self, forKey: .startDate)
	}
	
	/// Encoder
	/// - Parameter encoder: encoder used
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(state, forKey: .state)
		try container.encode(instantData, forKey: .instantData)
		try container.encode(sessionData, forKey: .sessionData)
		try container.encode(lapData, forKey: .lapData)
		try container.encode(startDate, forKey: .startDate)
	}
	
	/// Save encoded raw data to files in folder
	/// - Parameter folder: the folder to save the cache files
	public func cacheRawData(to folder: URL) throws {
		try rawData.cache(to: folder)
	}
	
	/// Deletes the cache files
	/// - Parameter folder: the folder that the cache files are located
	public func clearCache(in folder: URL) {
		rawData.clearCache(in: folder)
	}
	
	/// Load cache data from folder
	/// - Parameter folder: the folder that the cache files are located
	public func loadRawData(from folder: URL) async throws {
		rawData = try await AGAccumulatorRawData.load(from: folder)
	}
		
	// an accumulator gets instant values from somewhere and accumulates them into various things
	
	/// Add a instant value to the instant data, emerpheral.
	/// Although these are never cleared they are only really valid for a moment in time.
	/// - Parameters:
	///   - value: the value of the data type
	///   - type: data type to store.
	public func add(instant value: Double, type: AGDataType) {
		instantData[type] = AGInstantDataType(value: value)
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
		rawData.add(value: AGDataTypeValue(type: type, value: value), second: seconds, paused: state.isPaused())
	}
	
	/// Accumulate this data type with an array value
	/// - Parameters:
	///   - date: timestamp of data
	///   - arrayValue: an array of values.
	public func accumulate(date: Date, arrayValue: AGDataTypeArrayValue) throws {
		
		guard let startDate else {
			throw AGAccumlatorError.notRunning
		}
		
		let seconds = Int(timeInterval(for: date, since: startDate))
		rawData.add(arrayValue: arrayValue, second: seconds, paused: state.isPaused())
	}
	
	/// An even has occured process the data accordingly
	/// - Parameters:
	///   - event: the event tupe
	///   - date: the timestamp of the event.
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
	
	/// Start event
	/// - Parameter startDate: timestamp of the start event
	private func start(startDate: Date) {
		guard state == .stopped else {
			return
		}
		self.startDate = startDate
		self.lapData.start(startDate: startDate)
		self.sessionData.start(startDate: startDate)
		state = .running
	}
	
	/// A Pause event occured
	/// - Parameter date: timestamp of pause event
	private func pause(date: Date) {
		guard state == .running else {
			return
		}
		if sessionData.pause(date: date) && lapData.pause(date: date) {
			state = .paused
		}
	}
	
	/// Resume event occured
	/// - Parameter date: timestamp of the resume event
	private func resume(date: Date) {
		guard state.isPaused() else {
			return
		}
		if sessionData.resume(date: date) && lapData.resume(date: date) {
			state = .running
		}
	}
	
	/// A Stop event occurred.
	private func stop() {
		if state.isRunning() {
			state = .stopped
		}
	}
	
	/// Reset data request
	private func reset() {
		if state == .stopped {
			sessionData = AGAccumulatorMultiData()
			lapData = AGAccumulatorMultiData()
			rawData = AGAccumulatorRawData()
			instantData = [: ]
			startDate = nil
		}
	}
	
	/// Polling event occurred.
	/// - Parameter date: timestamp of the poll event.
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
