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
	case sparkle
	case introspect
	
	public var id: AGPackage {
		self
	}
	
	
	var title: String {
		switch self {
		case .alamofire:
			return "Alamofire"
		case .swiftStrava:
			return "SwiftStrava"
		case .sparkle:
			return "Sparkle"
		case .introspect:
			return "Introspect"
		}
	}
	
	var url: URL? {
		switch self {
		case .alamofire:
			return URL(string: "https://github.com/Alamofire/Alamofire")
		case .swiftStrava:
			return URL(string: "https://github.com/antokne/swift-strava")
		case .sparkle:
			return URL(string: "https://github.com/sparkle-project/Sparkle")
		case .introspect:
			return URL(string: "https://github.com/siteline/SwiftUI-Introspect")
		}
	}
}
