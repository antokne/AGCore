//
//  Data+Append.swift
//  Gruppo
//
//  Created by Antony Gardiner on 30/03/23.
//

import Foundation

extension Data {
	
	public mutating func appendUInt8(_ value: UInt8) {
		self.append(value)
	}
	
	/// Append a utf8 string null terminated.
	/// - Parameter value: the string to append
	public mutating func appendString(_ value: String) {
		if let value = value.data(using: .utf8) {
			self.append(value)
			self.append(0)
		}
	}
		
	public mutating func appendFloat(_ value: Float) {
		self.append(value.data)
	}
	
	public mutating func appendUInt32(_ value: UInt32) {
		self.append(value.data)
	}
	
}


extension Float {
	public var data: Data {
		Data(withUnsafeBytes(of: self, Array.init))
	}
}

extension UInt32 {
	var data: Data {
		Data(withUnsafeBytes(of: self, Array.init))
	}
}
