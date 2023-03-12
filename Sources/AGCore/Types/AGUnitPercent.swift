//
//  File.swift
//  
//
//  Created by Antony Gardiner on 13/03/23.
//

import Foundation


final public class AGUnitPercent: Dimension {
	
	private struct Symbol {
		static let percent      = "%"
	}
	
	/// Percentage Unit
	public class var percent: AGUnitPercent {
		return AGUnitPercent(symbol: Symbol.percent)
	}
}
