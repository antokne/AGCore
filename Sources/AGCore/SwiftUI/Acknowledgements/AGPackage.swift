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
	case antMessageProtocol
	case dataDecoder
	case fitnessUnits
	case polyline
	case swiftLocation
	case asyncBluetooth
	case fitDataProtocol
	case alertToast
	case dateBuilder
	case niceNotifications
	
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
		case .antMessageProtocol:
			return "AntMessageProtocol"
		case .dataDecoder:
			return "DataDecoder"
		case .fitnessUnits:
			return "FitnessUnits"
		case .polyline:
			return "Polyline"
		case .swiftLocation:
			return "SwiftLocation"
		case .asyncBluetooth:
			return "AsyncBluetooth"
		case .fitDataProtocol:
			return "FitDataProtocol"
		case .alertToast:
			return "AlertToast"
		case .dateBuilder:
			return "DateBuilder"
		case .niceNotifications:
			return "NiceNotifications"
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
		case .antMessageProtocol:
			return URL(string: "https://github.com/FitnessKit/AntMessageProtocol")
		case .dataDecoder:
			return URL(string: "https://github.com/fitnesskit/datadecoder")
		case .fitnessUnits:
			return URL(string: "https://github.com/FitnessKit/fitnessUnits")
		case .polyline:
			return URL(string: "https://github.com/raphaelmor/Polyline")
		case .swiftLocation:
			return URL(string: "https://github.com/malcommac/SwiftLocation")
		case .asyncBluetooth:
			return URL(string: "https://github.com/manolofdez/AsyncBluetooth")
		case .fitDataProtocol:
			return URL(string: "https://github.com/FitnessKit/FitDataProtocol")
		case .alertToast:
			return URL(string: "https://github.com/elai950/AlertToast")
		case .dateBuilder:
			return URL(string: "https://github.com/dreymonde/DateBuilder")
		case .niceNotifications:
			return URL(string: "https://github.com/dreymonde/NiceNotifications")
		}
	}
}
