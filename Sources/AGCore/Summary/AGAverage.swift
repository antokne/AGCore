//
//  AGAverage.swift
//  FitViewer
//
//  Created by Ant Gardiner on 17/07/18.
//  Copyright © 2018 Antokne. All rights reserved.
//

import Foundation

public enum AGDataType: Int {
	case speed
	case speedAccuracy
	case latitude
	case longitude
	case horizontalAccuracy
	case power
	case cadence
	case hr
	case distance
	case altitude
	case verticalAccuracy
	case ascent
	case descent
	case grade
	case calories
	case temperature
	/// Power left right balance as a percentage < 50% favours the left pedal > 50% favours the right.
	case lrBalance
	case torqueEffectivenessLeft
	case torqueEffectivenessRight
	case torqueEffectivenessCombined
	case pedalSmoothnessLeft
	case pedalSmoothnessRight
	case pedalSmoothnessCombined
	case timestamp
	case workoutTime
	case startTime
}

public struct AGDataTypeValue: Hashable {
	private(set) public var type: AGDataType
	private(set) public var value: Double
	
	public init(type: AGDataType, value: Double) {
		self.type = type
		self.value = value
	}
}

public enum AGAverageType: Int32 {
	case average = 0
	case max
	case min
	case range
	case accumulation
	case accumulationOverTime
	case last
	case first
	
	public static let items = [average, max, min, range, accumulation, accumulationOverTime, last, first]
}


/// Simple struct to store average type values.
public struct AGAverageTypeStruct {
	
	private var data = [AGAverageType: Double]()
	
	public init(data: [AGAverageType : Double] = [AGAverageType: Double]()) {
		self.data = data
	}
	
	/// For the standard period set all the average types
	///
	/// - Parameters:
	///   - avgType: average type
	///   - value: the value
	public mutating func set(avgType: AGAverageType, value: Double) {
		data[avgType] = value
	}
	
	/// Get the value for a specific average type
	///
	/// - Parameter averageType: average type to get
	/// - Returns: an unformated value for this avergae type
	public func get(valueForaverageType averageType: AGAverageType) -> Double? {
		return data[averageType]
	}
}

/// Struct that you can add data points and it will generate average type values.
public struct AGAverage {
	
	static let NotSet = Double.greatestFiniteMagnitude

	private var left: CGPoint
	private var right: CGPoint
	private var max: CGPoint
	private var min: CGPoint
	
	private var last: CGPoint
	private var first: CGPoint
	
	private(set) public var sum: Double = 0
	private(set) public var count: Int = 0
	
	private(set) public var type: AGDataType
	
	public init(type: AGDataType) {
		self.type = type
		left = AGAverage.getNotSetPpoint()
		right = AGAverage.getNotSetPpoint()
		max = AGAverage.getNotSetPpoint()
		min = AGAverage.getNotSetPpoint()
		last = AGAverage.getNotSetPpoint()
		first = AGAverage.getNotSetPpoint()
	}
	
	private static func getNotSetPpoint() -> CGPoint {
		CGPoint(x: NotSet, y: NotSet)
	}
	
	mutating func add(point: CGPoint) {
		add(x: point.x, y: point.y)
	}
	
	/// Add x and y actual values
	/// - Parameters:
	///   - x: x value
	///   - y: y value
	mutating func add(x: Double, y: Double) {
		
		if self.left.x == AGAverage.NotSet || x < self.left.x
		{
			self.left = CGPoint(x: x, y: y)
		}
		
		if self.right.x == AGAverage.NotSet || x > self.right.x
		{
			self.right = CGPoint(x: x, y: y)
		}
		
		if self.min.y == AGAverage.NotSet || y < self.min.y
		{
			self.min = CGPoint(x: x, y: y)
		}
		
		if self.max.y == AGAverage.NotSet || y > self.max.y
		{
			self.max = CGPoint(x: x, y: y)
		}
		
		if self.first.y == AGAverage.NotSet
		{
			self.first = CGPoint(x: x, y: y)
		}
		
		self.last = CGPoint(x: x, y: y)
		
		self.sum += y
		self.count += 1
	}
	
	/// add a value using deltas
	/// - Parameters:
	///   - dx: delta x
	///   - dy: delta y
	mutating func add(dx: Double, dy: Double) {
		add(x: self.last.x + dx, y: self.last.y + dy)
	}
	
	/// add a value for actual x value delta y
	/// - Parameters:
	///   - x: <#x description#>
	///   - dy: <#dy description#>
	mutating func add(x: Double, dy: Double) {
		add(x: x, y: self.last.y + dy)
	}
	
	/// add a delta x value actual y
	/// - Parameters:
	///   - dx: <#dx description#>
	///   - y: <#y description#>
	mutating func add(dx: Double, y: Double) {
		add(x: self.last.x + dx, y: y)
	}
	
	private func getAverage() -> Double? {
		if count > 0 {
			return sum / Double(count)
		}
		return nil
	}
	
	private func getAccummulatedAverage() -> Double? {
		let deltaSec = (self.right.x - self.left.x);
		if (deltaSec > 0)
		{
			let accum = self.right.y - self.left.y;
			return accum / deltaSec;
		}
		return nil
	}
	
	public func getValue(for avgType: AGAverageType) -> Double? {
		switch avgType {
		case .average:
			return getAverage()
		case .max:
			return max.y
		case .min:
			return min.y
		case .range:
			return max.y - min.y
		case .accumulation:
			return right.y - left.y
		case .accumulationOverTime:
			return getAccummulatedAverage()
		case .last:
			return right.y
		case .first:
			return left.y;
		}
	}
	
	public func stringValue() -> String {
		String(format: "SUM:%f Count:%d AVG:%f MAX:%f MIN:%f RANGE:%f ACCUM:%f ACCUM/TIME:%f FIRST:%f LAST:%f",
			   sum,
			   count,
			   getValue(for: .average) ?? -1,
			   getValue(for: .max) ?? -1,
			   getValue(for: .min) ?? -1,
			   getValue(for: .range) ?? -1,
			   getValue(for: .accumulation) ?? -1,
			   getValue(for: .accumulationOverTime) ?? -1,
			   getValue(for: .first) ?? -1,
			   getValue(for: .last) ?? -1
		)
	}
}
