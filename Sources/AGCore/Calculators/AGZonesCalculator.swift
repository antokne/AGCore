//
//  AGZonesCalculator.swift
//  
//
//  Created by Antony Gardiner on 27/02/23.
//

import Foundation

public class AGZonesCalculator {
	
	public private(set) var allZoneTypes: [AGZoneType: [AGTimeInZone]] = [:]
	
	public init() {
	}
	
	public func addZone(index: Int, type: AGZoneType, hiLimit: UInt16) {
		if var typeTimeInZones = getTimeInZones(for: type) {
			let timeInZone = AGTimeInZone(zone: AGZone(index: index, type: type, hiLimit: hiLimit), timeInZoneS: 0)
			typeTimeInZones.append(timeInZone)
			// ensure sorted lowest to highest.
			typeTimeInZones.sort { $0.zone.hiLimit < $1.zone.hiLimit }
			allZoneTypes[type] = typeTimeInZones
		}
	}
	
	/// added a 1 hz record to the time in zones record for specific type
	/// - Parameters:
	///   - type: type e.g. power or HR
	///   - instantValue: the value to use to select zone
	///   - timeDeltaS: usually 1 second (aka 1 Hz as per a standard fit file)
	public func add(type: AGZoneType, instantValue: Int, timeDeltaS: Int) {
		if let typeTimeInZones = getTimeInZones(for: type) {
			for timeInZone in typeTimeInZones {
				if instantValue < timeInZone.zone.hiLimit {
					timeInZone.timeInZoneS += timeDeltaS
					break
				}
			}
		}
	}
	
	private func getTimeInZones(for type: AGZoneType) -> [AGTimeInZone]? {
		
		if allZoneTypes[type] == nil {
			allZoneTypes[type] = []
		}
		
		guard let typeZones = allZoneTypes[type] else {
			return nil
		}
		return typeZones
	}
}
