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

public class AGUnitNone: Unit {
    
    // TODO: localize RPM
	public static let none = AGUnitNone(symbol: "")
    
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
