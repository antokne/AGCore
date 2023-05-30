//
//  AGAccumatorRawData.swift
//  
//
//  Created by Antony Gardiner on 30/05/23.
//

import Foundation

public struct AGAccumulatorRawInstantData {
	var instant: [AGDataType: Double] = [: ]
	var paused: Bool = false
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

	var rawData: [Int: AGAccumulatorRawInstantData] = [: ]
	
	mutating func add(value: AGDataTypeValue, second: Int, paused: Bool = false) {
		if rawData[second] == nil {
			rawData[second] = AGAccumulatorRawInstantData()
		}
		rawData[second]?.add(value: value)
		rawData[second]?.paused = paused
	}
	
	func value(for second: Int) -> AGAccumulatorRawInstantData? {
		rawData[second]
	}
	
	mutating func clear() {
		rawData = [:] // 💥
	}
}
