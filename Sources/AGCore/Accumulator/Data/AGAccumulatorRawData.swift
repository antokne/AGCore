//
//  AGAccumatorRawData.swift
//  
//
//  Created by Antony Gardiner on 30/05/23.
//

import Foundation

public struct AGAccumulatorRawInstantData {
	var instant: [AGDataType: Double] = [: ]
	internal(set) public var paused: Bool = false
	mutating func add(value: AGDataTypeValue) {
		instant[value.type] = value.value
	}
	
	public func value(for type: AGDataType) -> Double? {
		instant[type]
	}
}

/// A struct that contains all the data we are collecting whether paused or not.
/// This allows us to recontruct anything using this data.
/// Recorded at 1Hz as is the standard.
public struct AGAccumulatorRawData {
	
	/// All data added to raw data dict.
	private(set) public var data: [Int: AGAccumulatorRawInstantData] = [: ]
	
	mutating func add(value: AGDataTypeValue, second: Int, paused: Bool = false) {
		if data[second] == nil {
			data[second] = AGAccumulatorRawInstantData()
		}
		data[second]?.add(value: value)
		data[second]?.paused = paused
	}
	
	func value(for second: Int) -> AGAccumulatorRawInstantData? {
		data[second]
	}
	
	mutating func clear() {
		data = [:] // 💥
	}
}
