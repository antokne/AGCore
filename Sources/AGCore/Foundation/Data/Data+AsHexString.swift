//
//  Data+AsHexString.swift
//  Gruppo
//
//  Created by Antony Gardiner on 5/05/23.
//

import Foundation

extension Data {
	public struct HexEncodingOptions: OptionSet {
		public let rawValue: Int
		public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
	
	public func hexEncodedString(options: HexEncodingOptions = []) -> String {
		let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
		return self.map { String(format: format, $0) }.joined()
	}
}


extension String {
	
	public func asData() -> Data? {
		
		var data = Data()
		let integers = self.compactMap(\.hexDigitValue)
		for idx in stride(from: 0, to: integers.count, by: 2) {
			let int1 = UInt8(integers[idx])
			let int2 = UInt8(integers[idx + 1])
			let value = int1 * 16 + int2
			data.append(value)
		}
		return data
	}
	
	public func index(_ idx: Int) -> Index {
		self.index(self.startIndex, offsetBy: idx)
	}
}
