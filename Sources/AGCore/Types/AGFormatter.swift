//
//  AGFormatter.swift
//  FitViewer
//
//  Created by Ant Gardiner on 17/07/18.
//  Copyright © 2018 Antokne. All rights reserved.
//

import Foundation

public class AGFormatter: NSObject {
	
	public static let sharedFormatter = AGFormatter()

    // MARK: - Private
    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.roundingMode = .halfUp
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()
    
    private lazy var measurementFormatter: MeasurementFormatter = {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitStyle = .short
        measurementFormatter.numberFormatter = numberFormatter
        return measurementFormatter
    }()
    
    private var dateFormatter = DateFormatter()
    
    // MARK: - Public Formatting methods

    /// Format the date
    ///
    /// - Parameter date: date to format
    /// - Returns: a string using medium date style
    public func formatDate(date: Date) -> String {
        dateFormatter.dateFormat = nil
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    
    /// Format a date into time using the style short.
    ///
    /// - Parameter date: date to format
    /// - Returns: a string representing the time in short style.
    public func formatTime(date: Date) -> String {
        dateFormatter.dateFormat = nil
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    /// Format seconds correcly into hours, minutes & seconds
    ///
    /// - Parameter duration: duration in seconds
    /// - Returns: a formated string of format HH:MM:SS
    public func formatDuration(duration: Double) -> String {
			if duration < 60 {
			return "\(Int(duration))"
		}
		else if duration < 3600 {
			let mins = Int(duration / 60)
			let secs = Int(duration) - (mins * 60)
			return String(format: "%02d:%02d", mins, secs)// "\(mins):\(secs)"
		}
		else {
			let hrs = Int(duration / 60 / 60)
			let mins = Int(duration / 60) - (hrs * 60)
			let secs = Int(duration) - (mins * 60) - (hrs * 60 * 60)
			return String(format: "%d:%02d:%02d", hrs, mins, secs) //"\(hrs):\(mins):\(secs)"
		}
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
	
    
    /// Format a value based on it's unit
    ///
    /// - Parameters:
    ///   - value: the actual value
    ///   - unit: the unit the value is in
    ///   - provided: use the provided unit to format with otherwise the system default
    ///   - points: how many decimals after the point to display
    /// - Returns: a string formatted correctly including units if any.
    public func formatValue(value:Double, using unit:Unit, usingProvidedUnit provided: Bool, withDecimalPoints points:Int) -> String {
        let measurementValue = Measurement(value: value, unit:unit)
 
		measurementFormatter.numberFormatter.maximumFractionDigits = points
		measurementFormatter.numberFormatter.minimumFractionDigits = points
		
        // Odd thing about custom units is you need to specify that you want to use it.
        measurementFormatter.unitOptions = provided ? .providedUnit : .naturalScale
        
         return measurementFormatter.string(from: measurementValue)
    }
	
	public func formatDistanceValue(measurement: Measurement<UnitLength>, usingProvidedUnit provided: Bool, withDecimalPoints points:Int) -> String {
		
		measurementFormatter.numberFormatter.maximumFractionDigits = points
		measurementFormatter.numberFormatter.minimumFractionDigits = points

		// Odd thing about custom units is you need to specify that you want to use it.
		measurementFormatter.unitOptions = provided ? .providedUnit : .naturalScale
		
		return measurementFormatter.string(from: measurement)
	}
	
	public func formatSpeedValue(measurement: Measurement<UnitSpeed>, usingProvidedUnit provided: Bool, withDecimalPoints points:Int) -> String {
				
		measurementFormatter.numberFormatter.maximumFractionDigits = points
		measurementFormatter.numberFormatter.minimumFractionDigits = points
		
		// Odd thing about custom units is you need to specify that you want to use it.
		measurementFormatter.unitOptions = provided ? .providedUnit : .naturalScale

		return measurementFormatter.string(from: measurement)
	}
	
	public func formatUnitValue<U>(measurement: Measurement<U>, usingProvidedUnit provided: Bool = false, withDecimalPoints points:Int = 0) -> String {
		
		measurementFormatter.numberFormatter.maximumFractionDigits = points
		measurementFormatter.numberFormatter.minimumFractionDigits = points
		
		// Odd thing about custom units is you need to specify that you want to use it.

		let unit = measurement.unit
		return String(format: "%.*f %@", points, measurement.value, unit.symbol)
		
//		return measurementFormatter.string(from: measurement)
	}
}

// Simple quick conversions
public extension AGFormatter {
	func metersPerSecondToKilometersPerHour(mps: Double) -> Double {
		mps * 3.6
	}
	
	func metersPerSecondToMilesPerHour(mps: Double) -> Double {
		mps * 2.236936292
	}
	
	func metersTofeet(meters: Double) -> Double {
		meters * 3.280839895
	}
}
