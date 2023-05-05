//
//  Data+CRC32.swift
//  Gruppo
//
//  Created by Antony Gardiner on 5/04/23.
//

import Foundation


extension Data {
	public func checksum() -> UInt32 {
		let table: [UInt32] = {
			(0...255).map { i -> UInt32 in
				(0..<8).reduce(UInt32(i), { c, _ in
					(c % 2 == 0) ? (c >> 1) : (0xEDB88320 ^ (c >> 1))
				})
			}
		}()
		return ~(
			self.withUnsafeBytes({
				pointers in pointers.reduce(~UInt32(0), {
					crc, byte in (crc >> 8) ^ table[(Int(crc) ^ Int(byte)) & 0xFF]
				})
			})
		)
	}
}
