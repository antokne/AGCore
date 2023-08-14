//
//  AGDataType.swift
//  
//
//  Created by Ant Gardiner on 14/05/23.
//

import Foundation

public enum AGDataType: Int, Codable {
	case speed = 0
	case speedAccuracy = 1
	case latitude = 2
	case longitude = 3
	case horizontalAccuracy = 4
	case power = 5
	case cadence = 6
	case hr = 7
	case distance = 8
	case altitude = 9
	case verticalAccuracy = 10
	case ascent = 11
	case descent = 12
	case grade = 13
	case calories = 14
	case temperature = 15
	
	/// Power left right balance as a percentage <50% favours the left pedal > 50% favours the right.
	case lrBalance = 16
	case torqueEffectivenessLeft = 17
	case torqueEffectivenessRight = 18
	case torqueEffectivenessCombined = 19
	case pedalSmoothnessLeft = 20
	case pedalSmoothnessRight = 21
	case pedalSmoothnessCombined = 22
	case timestamp = 23
	case workoutTime = 24
	case startTime = 25
	
	/// An array of range values for each target in m
	case radarRanges = 26
	
	/// An array of speed values for each target in m/s
	case radarSpeeds = 27
	
	/// Number of targets currently in range
	case radarTargetCount = 28
	
	/// total number of targets detected
	case radarTargetTotalCount = 29
	
	/// Speed in m/s that a target approaches at
	case radarPassingSpeed = 30
	
	// the difference between speed of target and current speed.
	case radarPassingSpeedAbs = 31
	
	/// What is the current status of the radar. connected 1 or disconnected 0?
	case radarStatus = 32
	
	public var units: Dimension {
		switch self {
		case .speed:
			return UnitSpeed.metersPerSecond
		case .speedAccuracy:
			return UnitSpeed.metersPerSecond
		case .latitude:
			return UnitAngle.degrees
		case .longitude:
			return UnitAngle.degrees
		case .horizontalAccuracy:
			return UnitLength.meters
		case .power:
			return UnitPower.watts
		case .cadence:
			return AGUnitRevolutions.rpm
		case .hr:
			return AGUnitHeartrate.bpm
		case .distance:
			return UnitLength.meters
		case .altitude:
			return UnitLength.meters
		case .verticalAccuracy:
			return UnitLength.meters
		case .ascent:
			return UnitLength.meters
		case .descent:
			return UnitLength.meters
		case .grade:
			return AGUnitPercent.percent
		case .calories:
			return UnitEnergy.kilocalories
		case .temperature:
			return UnitTemperature.celsius
		case .lrBalance:
			return AGUnitPercent.percent
		case .torqueEffectivenessLeft:
			return AGUnitPercent.percent
		case .torqueEffectivenessRight:
			return AGUnitPercent.percent
		case .torqueEffectivenessCombined:
			return AGUnitPercent.percent
		case .pedalSmoothnessLeft:
			return AGUnitPercent.percent
		case .pedalSmoothnessRight:
			return AGUnitPercent.percent
		case .pedalSmoothnessCombined:
			return AGUnitPercent.percent
		case .timestamp:
			return UnitDuration.seconds
		case .workoutTime:
			return UnitDuration.seconds
		case .startTime:
			return AGUnitTime.time
		case .radarRanges:
			return UnitLength.meters
		case .radarSpeeds:
			return UnitSpeed.metersPerSecond
		case .radarTargetTotalCount:
			return AGUnitNone.none
		case .radarPassingSpeed:
			return UnitSpeed.metersPerSecond
		case .radarPassingSpeedAbs:
			return UnitSpeed.metersPerSecond
		case .radarTargetCount:
			return AGUnitNone.none
		case .radarStatus:
			return AGUnitNone.none
		}
	}
	
	public var displayedDimension: Dimension {
		let metric = Locale.current.measurementSystem == .metric
		switch self {
		case .speed, .speedAccuracy:
			return metric ? UnitSpeed.kilometersPerHour : UnitSpeed.milesPerHour
		case .latitude, .longitude:
			return UnitAngle.degrees
		case .horizontalAccuracy:
			return UnitLength.meters
		case .power:
			return UnitPower.watts
		case .cadence:
			return AGUnitRevolutions.rpm
		case .hr:
			return AGUnitHeartrate.bpm
		case .distance:
			return metric ? UnitLength.kilometers : UnitLength.miles
		case .altitude, .verticalAccuracy, .ascent, .descent:
			return metric ? UnitLength.meters : UnitLength.feet
		case .grade:
			return AGUnitPercent.percent
		case .calories:
			return UnitEnergy.kilocalories
		case .temperature:
			return metric ? UnitTemperature.celsius : UnitTemperature.fahrenheit
		case .lrBalance,
				.torqueEffectivenessLeft,
				.torqueEffectivenessRight,
				.torqueEffectivenessCombined,
				.pedalSmoothnessLeft,
				.pedalSmoothnessRight,
				.pedalSmoothnessCombined:
			return AGUnitPercent.percent
		case .timestamp:
			return AGUnitNone.none
		case .workoutTime:
			return AGUnitNone.none
		case .startTime:
			return AGUnitNone.none
		case .radarRanges:
			return metric ? UnitLength.meters : UnitLength.feet
		case .radarSpeeds:
			return metric ? UnitSpeed.kilometersPerHour : UnitSpeed.milesPerHour
		case .radarTargetTotalCount:
			return AGUnitNone.none
		case .radarPassingSpeed:
			return metric ? UnitSpeed.kilometersPerHour : UnitSpeed.milesPerHour
		case .radarPassingSpeedAbs:
			return metric ? UnitSpeed.kilometersPerHour : UnitSpeed.milesPerHour
		case .radarTargetCount:
			return AGUnitNone.none
		case .radarStatus:
			return AGUnitNone.none
		}
	}
	
	var precision: Int {
		switch self {
		case .speed, .speedAccuracy:
			return 1
		case .latitude, .longitude:
			return 5
		case .horizontalAccuracy:
			return 0
		case .power:
			return 0
		case .cadence:
			return 0
		case .hr:
			return 0
		case .distance:
			return 1
		case .altitude, .verticalAccuracy, .ascent, .descent:
			return 0
		case .grade:
			return 0
		case .calories:
			return 0
		case .temperature:
			return 0
		case .lrBalance,
				.torqueEffectivenessLeft,
				.torqueEffectivenessRight,
				.torqueEffectivenessCombined,
				.pedalSmoothnessLeft,
				.pedalSmoothnessRight,
				.pedalSmoothnessCombined:
			return 0
		case .timestamp:
			return 0
		case .workoutTime:
			return 0
		case .startTime:
			return 0
		case .radarRanges:
			return 0
		case .radarSpeeds:
			return 0
		case .radarTargetTotalCount:
			return 0
		case .radarPassingSpeed:
			return 0
		case .radarPassingSpeedAbs:
			return 0
		case .radarTargetCount:
			return 0
		case .radarStatus:
			return 0
		}
	}
	
	public func format(value: Double) -> String {
		switch self {
		case .workoutTime, .startTime:
			return AGFormatter.durationFormat(timeInterval: value)
		default:
			let measurement = Measurement(value: value, unit: self.units)
			let convertTo = self.displayedDimension
			let convertedValue = measurement.converted(to: convertTo)
			return String(format: "%.*f", self.precision, convertedValue.value)
		}
	}
}

public struct AGDataTypeValue: Hashable, Codable {
	private(set) public var type: AGDataType
	private(set) public var value: Double
	
	public init(type: AGDataType, value: Double) {
		self.type = type
		self.value = value
	}
}

public struct AGDataTypeArrayValue: Hashable, Codable {
	private(set) public var type: AGDataType
	private(set) public var values: [Double]
	
	public init(type: AGDataType, values: [Double]) {
		self.type = type
		self.values = values
	}
}
