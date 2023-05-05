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
