//
//  AGAccumulatorPausedData.swift
//  
//
//  Created by Antony Gardiner on 30/05/23.
//

import Foundation

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
