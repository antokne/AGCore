//
//  AGInstantDataType.swift
//  
//
//  Created by Ant Gardiner on 13/07/23.
//
import Foundation

public struct AGInstantDataType: Codable {
	
	public static var staleInterval: TimeInterval = 5
	
	/// The value for this instant in time
	public var value: Double
	
	/// The time that this value was registered.
	public var date: Date
	
	init(value: Double, date: Date = Date()) {
		self.value = value
		self.date = date
	}
	
	/// If time since this value was set and now is > staleInterval report as stale.
	public var stale: Bool {
		return date.timeIntervalSinceNow < -AGInstantDataType.staleInterval
	}
}
