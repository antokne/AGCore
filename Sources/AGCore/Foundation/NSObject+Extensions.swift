//
//  File.swift
//  
//
//  Created by Antony Gardiner on 5/05/23.
//

import Foundation

extension NSObject {
	public static var className: String {
		String(describing:self)
	}
}
