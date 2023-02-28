//
//  AGZones.swift
//  
//
//  Created by Antony Gardiner on 27/02/23.
//

import Foundation

public enum AGZoneType: Int {
	case heartrate
	case power
}

public struct AGZone {
	var index: Int
	var type: AGZoneType
	var hiLimit: UInt16
}

public class AGTimeInZone: NSObject {
	var zone: AGZone
	var timeInZoneS : Int
	
	public init(zone: AGZone, timeInZoneS: Int) {
		self.zone = zone
		self.timeInZoneS = timeInZoneS
	}
	
	override public var description: String {
		String(format: "index:%d type: %d HiLimit: %d TimeInZone:%d", zone.index, zone.type.rawValue, zone.hiLimit, timeInZoneS)
	}
}


