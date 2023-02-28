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
	case power
	case cadence
	case hr
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


/// OMG I created a struct with methods
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



public struct AGAverage {
	
	static let NotSet = Double.greatestFiniteMagnitude

	var left: CGPoint
	var right: CGPoint
	var top: CGPoint
	var bottom: CGPoint
	
	var last: CGPoint
	var first: CGPoint
	
	var sum: Double = 0
	var count: Int = 0
	
	var type: AGDataType
	
	public init(type: AGDataType) {
		self.type = type
		left = AGAverage.getNotSetPpoint()
		right = AGAverage.getNotSetPpoint()
		top = AGAverage.getNotSetPpoint()
		bottom = AGAverage.getNotSetPpoint()
		last = AGAverage.getNotSetPpoint()
		first = AGAverage.getNotSetPpoint()
	}
	
	private static func getNotSetPpoint() -> CGPoint {
		CGPoint(x: NotSet, y: NotSet)
	}
	
	mutating func add(x: Double, y: Double) {
		
		if self.left.x == AGAverage.NotSet || x < self.left.x
		{
			self.left = CGPoint(x: x, y: y)
		}
		
		if self.right.x == AGAverage.NotSet || x > self.right.x
		{
			self.right = CGPoint(x: x, y: y)
		}
		
		if self.bottom.y == AGAverage.NotSet || y < self.bottom.y
		{
			self.bottom = CGPoint(x: x, y: y)
		}
		
		if self.top.y == AGAverage.NotSet || y > self.top.y
		{
			self.top = CGPoint(x: x, y: y)
		}
		
		if self.first.y == AGAverage.NotSet
		{
			self.first = CGPoint(x: x, y: y)
		}
		
		self.last = CGPoint(x: x, y: y)
		
		self.sum += y
		self.count += 1
	}
	
	mutating func add(dx: Double, dy: Double) {
		add(x: self.last.x + dx, y: self.last.y + dy)
	}
	
	mutating func add(x: Double, dy: Double) {
		add(x: x, y: self.last.y + dy)
	}
	
	mutating func add(dx: Double, y: Double) {
		add(x: self.last.x + dx, y: y)
	}
	
	func getAverage() -> Double? {
		if count > 0 {
			return sum / Double(count)
		}
		return nil
	}
	
	func getAccummulatedAverage() -> Double? {
		let deltaSec = (self.right.x - self.left.x) / 1000;
		if (deltaSec > 0)
		{
			let accum = self.right.y - self.left.y;
			return accum / deltaSec;
		}
		return nil
	}
	
	func getValue(for avgType: AGAverageType) -> Double? {
		switch avgType {
		case .average:
			return getAverage()
		case .max:
			return top.y
		case .min:
			return bottom.y
		case .range:
			return top.y - bottom.y
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
	
	func stringValue() -> String {
		String(format: "AVG:%f MAX:%f MIN:%f RANGE:%f ACCUM:%f ACCUM/TIME:%f FIRST:%f LAST:%f",
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
