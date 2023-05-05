//
//  Data+Remove.swift
//  Gruppo
//
//  Created by Antony Gardiner on 30/03/23.
//

import Foundation

extension Data {
	
	public mutating func removeUInt8() -> UInt8 {
		self.removeFirst()
	}
	
	public func decimalValue() -> Int {
		let decimalValue = self.reduce(0) { v, byte in
			return v << 8 | Int(byte)
		}
		return decimalValue
	}
	
	public mutating func removeUInt16() -> UInt16 {
		var data = Data()
		data.append(self.removeFirst())
		data.append(self.removeFirst())
		
		return UInt16(bigEndian: UInt16(data.decimalValue()))
	}
	
	public mutating func removeUInt32() -> UInt32 {
		var data = Data()
		data.append(self.removeFirst())
		data.append(self.removeFirst())
		data.append(self.removeFirst())
		data.append(self.removeFirst())

		return UInt32(bigEndian: UInt32(data.decimalValue()))
	}

	
	/// Extract a utf8 null terminated string from the buffer and remove
	/// - Returns: the string
	public mutating func removeString() -> String? {
		
		var bytes: [UInt8] = []
		
		var currentByte = self.removeUInt8()
		
		while currentByte != 0 {
			bytes.append(currentByte)
			
			currentByte = self.removeUInt8()
		}
		
		return String(bytes: bytes, encoding: .utf8)
	}
}
