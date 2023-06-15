//
//  AGUnits.swift
//  FitViewer
//
//  Created by Ant Gardiner on 17/07/18.
//  Copyright © 2018 Antokne. All rights reserved.
//

import Foundation

/// A custom unit for RPM
public class AGUnitRevolutions: Dimension {
    
    // TODO: localize RPM
    public static let rpm = AGUnitRevolutions(symbol: "rpm", converter: UnitConverterLinear(coefficient: 1.0))
    
    override public class func baseUnit() -> Self {
		return rpm as! Self
    }
}

public class AGUnitNone: Dimension {
    
    // TODO: localize RPM
	public static let none = AGUnitNone(symbol: "", converter: UnitConverterLinear(coefficient: 1.0))
	
	override public class func baseUnit() -> Self {
		none as! Self
	}
    
}

public class AGUnitHeartrate: Dimension {

	// TODO: localize BPM
	public static let bpm = AGUnitHeartrate(symbol: "bpm", converter: UnitConverterLinear(coefficient: 1.0))

	override public class func baseUnit() -> Self {
		return bpm as! Self
	}
}



public class AGUnitPercent: Dimension {
	
	private struct Symbol {
		static let percent      = "%"
	}
	
	/// Percentage Unit
	public class var percent: AGUnitPercent {
		return AGUnitPercent(symbol: Symbol.percent)
	}
}

public class AGUnitBoolean : Dimension {
	
	private struct Symbol {
		static let bool      = "Bool"
	}
	
	public class var bool: AGUnitBoolean {
		return AGUnitBoolean(symbol: Symbol.bool)
	}

}

public class AGUnitTime : Dimension {
	
	private struct Symbol {
		static let time      = "hms"
	}
	
	public class var time: AGUnitTime {
		return AGUnitTime(symbol: Symbol.time)
	}
	
}
