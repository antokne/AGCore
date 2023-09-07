//
//  Integer+Extensions.swift
//  
//
//  Created by Antony Gardiner on 8/05/23.
//

import Foundation


extension UInt8 {
	
	/// Calculates the bit mask for extracting x bits from a byte
	/// - Parameter bits: number of bits to extract 0-7
	/// - Returns: the binary mask to extract those bits
	public static func mask(for bits: UInt8) -> UInt8 {
		
		let fullMask = UInt8(0b11111111)
		
		guard bits >= 0 && bits <= 7 else {
			return fullMask
		}
		
		return fullMask >> (7 - bits)
	}
	
	public func extractBits(using mask: UInt8) -> UInt8 {
		self & mask
	}
	
	
	public func hexString() -> String {
		var string = String(self, radix: 2)
		while string.count < 8 {
			string = "0" + string
		}
		return string
	}

}


