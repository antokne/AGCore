//
//  AGBikePowerCalculator.swift
//  
//
//  Created by Antony Gardiner on 24/02/23.
//

import Foundation

public struct AGNormalizedPowerData {
	
	/// the calculated normalised power (w)
	public fileprivate(set) var normalisedPower: Double = -1
	
	/// the calculated intensity factor
	public fileprivate(set) var intensityFactor: Double = -1
	
	/// Calculated training stress score
	public fileprivate(set) var trainingStressScore: Double = 0
	
	/// energy used  in joules
	public fileprivate(set) var energy: Double = 0
	
	/// The functional threshold power used during the calculations
	public fileprivate(set) var ftp: Double
	
	public var description: String {
		String(format: "ftp:%f np:%f if:%f, tss:%f kj:%f", ftp, normalisedPower, intensityFactor, trainingStressScore, energy / 1000.0)
	}
	
}

fileprivate struct AGNomalizedPowerCalcData {
	var sum: Double
	var count: Int
	var activeDurationMs: Int = 0
	
	mutating func addPower(power: Double) {
		sum += pow(power, 4)
		count += 1
	}
	
	func currentPower() -> Double {
		pow(sum / Double(count), 0.25)
	}
}

public class AGBikePowerCalculator: NSObject {
	
	/// Set of power data
	public private(set) var normalizedPowerData: AGNormalizedPowerData
		
	private var normalizedPowerCalc: AGNomalizedPowerCalcData = AGNomalizedPowerCalcData(sum: 0, count: 0)
	
	/// Moving average calculator for 30 seconds
	private var movingAverage30s: AGMovingAverage = AGMovingAverage(ms: 30000)

	public init(ftp: Double) {
		normalizedPowerData = AGNormalizedPowerData(ftp: ftp)
	}
	
	public override var description: String  {
		"power data \(normalizedPowerData) moving avg 30s \(movingAverage30s.stringValue)"
	}
	
	/// Add the energy consumed for this time instance
	/// - Parameters:
	///   - deltaWork: work in joules
	///   - ms: millisecond offset since start of workout
	public func addDeltaWork(deltaWork: Double, deltaMs: Int) {
		
		// increment duration
		normalizedPowerCalc.activeDurationMs += deltaMs
		
		// add energy
		normalizedPowerData.energy += deltaWork
		
		// update moving average
		movingAverage30s.addTime(ms: normalizedPowerCalc.activeDurationMs, deltaValue: deltaWork)
		
		// if not enough data yet skip for now.
		let powerMAve30s = movingAverage30s.getValue(for: .accumulationOverTime)
		if powerMAve30s < 0 {
			return
		}
		
		// Update normalized power
		// * 1. Calculate 30-second rolling average power
		// * 2. Raise value obtained in step 1 to fourth power
		// * 3. Take average of all values obtained in step 2
		// * 4. Take fourth root of number obtained in step 3
		
		normalizedPowerCalc.addPower(power: powerMAve30s)
		normalizedPowerData.normalisedPower = normalizedPowerCalc.currentPower()
		
		// IF
		// IF = NP/ftp
		normalizedPowerData.intensityFactor = normalizedPowerData.normalisedPower / normalizedPowerData.ftp
		
		// TSS
		// * TSS = (duration x NP x IF) / (FTP x 3600) x 100
		// * which reduces to
		// * TSS = duration x IF^2 / 36
		let activeDurationS = Double(normalizedPowerCalc.activeDurationMs) / 1000.0
		normalizedPowerData.trainingStressScore = activeDurationS * pow(normalizedPowerData.intensityFactor, 2) / 36
	}

}
