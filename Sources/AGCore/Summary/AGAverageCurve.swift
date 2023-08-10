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
	private var bestPoints: [AGAverageCurvePoint] = []

	public init(totalActivityTimeS: Int) {
		self.totalActivityTimeS = totalActivityTimeS
	}
	
	/// Create an array of curve point data for number of seconds to calculate average for.
	/// This is dependant on total time of the activity.
	///
	/// Rules are:
	///  * Under 5 seconds a curve point every second.
	///  * Under 30s a curve point every 5 s
	///  * Under 1 min a  curve point every 30 s
	///  * Under 10m a curve point every 1m
	///  * Under 1hr a curve point every 10m
	///  * over 1 hour a  curve point every 1 hr.
	private func createPoints() {
				
		// get whole minutes and at least 1.
		//let totalTimeM = Int(max(ceil(Double(self.totalActivityTimeS) / 60.0), 1))
		
		var step = 1
		while step <= self.totalActivityTimeS {
			
			let point = AGAverageCurvePoint(seconds: step)
			workingPoints.append(point)

			switch step {
			case _ where step >= 3600: 	// over an hour add a point for each hour
				step += 3600
			case _ where step >= 600:	// Over 10m add a point for each 10m interval
				step += 600
			case _ where step >= 60:	// Over 1 min add a point for every 1m
				step += 60
			case _ where step >= 30:	// over 30s add point for every 30s.
				step += 30
			case _ where step >= 5:		// Over 5s add a point every 5s
				step += 5
			default:					// Otherwise add a point for every second.
				step += 1
			}
		}
		
		// A copy because structs are value types!
		bestPoints = workingPoints
	}
	
	public func reset() {
		workingPoints = []
		bestPoints = []
	}
	
	/// Added a value for this time in seconds from start of activity
	/// Assumes normalised to 1 second.
	/// - Parameters:
	///   - value: the value to add
	public func add(value: Int) {
		
		if workingPoints.count == 0 {
			createPoints()
		}
		
		for index in 0..<workingPoints.count {
			
			// if the added count is less than current seconds just add it
			if workingPoints[index].added < workingPoints[index].seconds {
				workingPoints[index].add(value: value)
			}
			else {
				// remove oldest value
				workingPoints[index].removeOldest()
				
				// move start time ahead one second
				workingPoints[index].startTimeS += 1
				
				// add new value
				workingPoints[index].add(value: value)
			}
			
			if bestPoints[index].sum < workingPoints[index].sum {
				bestPoints[index] = workingPoints[index]
			}
		}
	}
	
	/// Returns the current best avergae curve points
	public var points: [AGAverageCurvePoint] {
		bestPoints
	}
}
