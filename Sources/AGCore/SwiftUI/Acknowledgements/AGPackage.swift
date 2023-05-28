//
//  AGPackage.swift
//  
//
//  Created by Antony Gardiner on 26/05/23.
//

import Foundation

public enum AGPackage: Identifiable, CaseIterable {
	case alamofire
	case swiftStrava
	
	public var id: AGPackage {
		self
	}
	
	
	var title: String {
		switch self {
		case .alamofire:
			return "Alamofire"
		case .swiftStrava:
			return "SwiftStrava"
		}
	}
	
	var url: URL? {
		switch self {
		case .alamofire:
			return URL(string: "https://github.com/Alamofire/Alamofire")
		case .swiftStrava:
			return URL(string: "https://github.com/antokne/swift-strava")
		}
	}
}
