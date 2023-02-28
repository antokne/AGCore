//
//  AGAverageCurve.swift
//  
//
//  Created by Antony Gardiner on 24/02/23.
//

import Foundation

public struct AGAverageCurvePoint {
	
	var seconds: Int		/// seconds into activity this point is currently calculating for
	var sum: Int = 0
	var values: [Int] = []
	var added: Int 	= 0		/// Number of values added
	var startTimeS: Int = 0	/// offset in seconds from where this starts
	
	init(seconds: Int) {
		self.seconds = seconds
	}
	
	fileprivate mutating func add(value: Int) {
		sum += value
		values.append(value)
		added += 1
	}
	
	fileprivate mutating func removeOldest() {
		if let first = values.first {
			sum -= first
			values.removeFirst()
		}
	}
	
	public func getAverage() -> Double {
		return Double(sum) / Double(seconds)
	}
}

public class AGAverageCurve: NSObject {
	
	let totalActivityTimeS: Int
	
	private var workingPoints: [AGAverageCurvePoint] = []

	public init(totalActivityTimeS: Int) {
		self.totalActivityTimeS = totalActivityTimeS
	}
	
	private func createPoints() {
				
		// get whole minutes and at least 1.
		let totalTimeM = Int(max(ceil(Double(self.totalActivityTimeS) / 60.0), 1))
		
		var step = 1
		while step < totalTimeM {
			
			let point = AGAverageCurvePoint(seconds: step)
			workingPoints.append(point)

			switch step {
			case _ where step >= 3600: 	// over an hour add a point for each hour
				step += 900
			case _ where step >= 600:	// Over 10m add a point for each 10m interval
				step += 600
			case _ where step >= 60:	// Over 1 min add a point for every 1m
				step += 60
			case _ where step >= 20:	// Over 20s add a point every 5s
				step += 5
			default:
				step += 1
			}
		}
	}
	
	public func reset() {
		workingPoints = []
	}
	
	/// Added a value for this time in seconds from start of activity
	/// Assumes normalised to 1 second.
	/// - Parameters:
	///   - value: the value to add
	public func add(value: Int) {
		
		if workingPoints.count == 0 {
			createPoints()
		}
		
		for var currentPoint in workingPoints {
			
			// if the added count is less than current seconds just add it
			if currentPoint.added < currentPoint.seconds {
				currentPoint.add(value: value)
			}
			else {
				// remove oldest value
				currentPoint.removeOldest()
				
				// move start time ahead one second
				currentPoint.startTimeS += 1
				
				// add new value
				currentPoint.add(value: value)
				
			}
		}
	}
	
	public var points: [AGAverageCurvePoint] {
		workingPoints
	}
}
