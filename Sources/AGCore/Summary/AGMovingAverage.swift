//
//  AGMovingAverage.swift
//  
//
//  Created by Antony Gardiner on 24/02/23.
//

import Foundation

public struct AGMovingAverageValue: Equatable {
	var ms: Int
	var value: Double
}

public class AGMovingAverage: NSObject {
	
	public var ms: Int
	public var sum: Double = 0
	
	private var min: Int = Int.max
	private var max: Int = Int.min
	
	private var full: Bool = false
	
	private var entries: [AGMovingAverageValue] = []
	
	private var maxEntrySize: Int = 0
	
	init(ms: Int, sum: Double = 0) {
		self.ms = ms
		self.sum = sum
	}
	
	public func reset() {
		min = Int.max
		max = Int.min
		entries.removeAll()
		full = false
		maxEntrySize = 0
	}
	
	var stringValue: String {
		String(format: "ms:%d sum:%f min:%d max:%d entry count:%d", ms, sum, min, max, maxEntrySize, entries.count)
	}
	
	public func add(ms: Int, value: Double) {
		add(entry: AGMovingAverageValue(ms: ms, value: value))
	}
	
	public func addDeltaTime(deltaMs: Int, deltaValue: Double) {
		if let last = entries.last {
			add(ms: last.ms + deltaMs, value: last.value + deltaValue)
		}
		else {
			add(ms: deltaMs, value: deltaValue)
		}
	}

	public func addDeltaTime(deltaMs: Int, value: Double) {
		if let last = entries.last {
			add(ms: last.ms + deltaMs, value: value)
		}
		else {
			add(ms: deltaMs, value: value)
		}
	}
	
	public func addTime(ms: Int, deltaValue: Double) {
		if let last = entries.last {
			add(ms: ms, value: last.value + deltaValue)
		}
		else {
			add(ms: ms, value: deltaValue)
		}
	}

	
	private func add(entry: AGMovingAverageValue) {
		entries.append(entry)
		sum += entry.value
		
		let intValue = Int(entry.value)
		
		var maxAdded = false
		if intValue > max {
			max = intValue
			maxAdded = true
		}
		
		var minAdded = false
		if intValue < min {
			min = intValue
			minAdded = true
		}
		
		var maxRemoved = false
		var minRemoved = false
		
		var entriesToRemove: [AGMovingAverageValue] = []
		
		for currentEntry in entries {
			
			let deltaMs = entry.ms - currentEntry.ms
			
			// if this entry is outside the move average period
			if deltaMs > ms {
				
				// remove the entry
				entriesToRemove.append(currentEntry)
				
				// update sum
				sum -= currentEntry.value
				
				// mark max dirty if removed entry was max
				if !maxAdded && Int(currentEntry.value) == max {
					maxRemoved = true
				}
				
				// mark min dirty if removed entry was min
				if !minAdded && Int(currentEntry.value) == min {
					minRemoved = true
				}
				
				full = true
			}
			else {
				// stop
				break
			}
		}
	
		// filter out entries that need to be removed.
		entries = entries.filter { entriesToRemove.contains($0) == false }
		
		if maxRemoved || minRemoved {
			
			min = Int.max
			max = Int.min
			for entry in entries {
				
				let intValue = Int(entry.value)

				if intValue > max {
					max = intValue
				}
				if intValue < min {
					min = intValue
				}
			}
		}
		maxEntrySize = Swift.max(maxEntrySize, entries.count)
	}
	
	private func average(defaultValue: Double) -> Double {
		if entries.count > 0 {
			return Double(sum) / Double(entries.count)
		}
		return defaultValue
	}
	
	private func max(defaultValue: Double) -> Double {
		if max != Int.min {
			return Double(max)
		}
		return defaultValue
	}

	private func min(defaultValue: Double) -> Double {
		if min != Int.max {
			return Double(min)
		}
		return defaultValue
	}
	
	private func accumulatedAverage(defaultValue: Double) -> Double {
		
		if entries.count > 0 {
			
			guard let first = entries.first else {
				return defaultValue
			}
			guard let last = entries.last else {
				return defaultValue
			}
			
			let deltaMs = last.ms - first.ms
			if deltaMs > 0 {
				let deltaSec = deltaMs / 1000
				let deltaValue = last.value - first.value
				return deltaValue / Double(deltaSec)
			}
			else if maxEntrySize >= 2 {
				return 0
			}
		}
		
		return defaultValue
	}
	
	public func getValue(for averageType: AGAverageType, defaultValue: Double = -1) -> Double {
		var value = defaultValue
		
		switch averageType {
		case .average:
			value = average(defaultValue: defaultValue)
		case .max:
			value = max(defaultValue: defaultValue)
		case .min:
			value = min(defaultValue: defaultValue)
		case .accumulationOverTime:
			value = accumulatedAverage(defaultValue: defaultValue)
		case .range, .accumulation, .last, .first:
			break
		}
		
		return value
	}
	

}
