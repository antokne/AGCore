//
//  ViewModel.swift
//  RaceWeight
//
//  Created by Antony Gardiner on 15/12/22.
//
import Foundation

open class ViewModel {
	
	public static let defaultMinFractionDigits = 2
	
	public init() {
		
	}
	
	public static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale.current
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		return formatter
	}()
	
	public static func dateFormat(date: Date) -> String {
		dateFormatter.string(from: date)
	}
	
	public static func dateFrom(string: String) -> Date? {
		dateFormatter.date(from: string)
	}
	
	public static let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale.current
		formatter.dateStyle = .none
		formatter.timeStyle = .short
		return formatter
	}()
	
	public static func startTimeFormat(date: Date) -> String {
		timeFormatter.string(from: date)
	}

	public static func durationFormat(timeInterval: TimeInterval) -> String {
		let duration = Duration.seconds(timeInterval)

		var pattern = Duration.TimeFormatStyle.Pattern.hourMinute
		
		switch timeInterval {
		case 3600...86400:
			pattern = Duration.TimeFormatStyle.Pattern.hourMinuteSecond
		case 86400...2628288:
			let days = Int(timeInterval / 86400.0)
			return "\(days) " + "days"
		case 2628288...31557600:
			let months = Int(timeInterval / 2628288.0)
			return "\(months) " + "months"
		case 31557600...:
			let years = Int(timeInterval / 31557600.0)
			return "\(years) " + "years"
		default:
			pattern = Duration.TimeFormatStyle.Pattern.minuteSecond
		}
		
		return duration.formatted(.time(pattern: pattern))
	}
	
	public static var distanceFormatter: MeasurementFormatter = {
		let formatter = MeasurementFormatter()
		formatter.locale = Locale.current
		formatter.numberFormatter.maximumFractionDigits = defaultMinFractionDigits
		return formatter
	}()
	
	public static func distanceFormat(distanceM: Double, precision: Int = defaultMinFractionDigits) -> String {
		let distance = Measurement(value: distanceM, unit: UnitLength.meters)
		distanceFormatter.numberFormatter.maximumFractionDigits = precision
		return distanceFormatter.string(from: distance)
	}
	
	public  static var speedFormatter: MeasurementFormatter = {
		let formatter = MeasurementFormatter()
		formatter.locale = Locale.current
		formatter.numberFormatter.maximumFractionDigits = 0
		return formatter
	}()
	
	public static func speedFormat(speedMPS: Double, precision: Int = 0) -> String {
		let speed = Measurement(value: speedMPS, unit: UnitSpeed.metersPerSecond)
		speedFormatter.numberFormatter.maximumFractionDigits = precision
		return speedFormatter.string(from: speed)
	}
		
	public static func calorieFormat(calories: Int32) -> String {
		let calorieMesurement = Measurement(value: Double(calories), unit: UnitEnergy.kilocalories)
		return calorieMesurement.formatted(.measurement(width: .abbreviated, usage: .asProvided))
	}
	
	public static func powerFormat(powerW: Double) -> String {
		let power = Measurement(value: powerW, unit: UnitPower.watts)
		return power.formatted()
	}
	
	public static func elevationFormat(elevationM: Double) -> String {
		let elevation = Measurement(value: elevationM, unit: UnitLength.meters)
		let metric = Locale.current.measurementSystem
		let convertedElevation = elevation.converted(to: (metric == .metric ? UnitLength.meters : UnitLength.feet))
		return convertedElevation.formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: FloatingPointFormatStyle.number.precision(.fractionLength(0))))
	}
}
