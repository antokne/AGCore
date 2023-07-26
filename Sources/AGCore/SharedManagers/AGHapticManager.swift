//
//  AGHapticManager.swift
//  
//
//  Created by Ant Gardiner on 25/07/23.
//

import Foundation
import OSLog
import CoreHaptics

public enum AGHapticError: Error {
	case hapticFileNotFound
	case hapticPatternNotFound
	case hapticEngineNotRunning
}

public class AGHapticManager: ObservableObject {
	
	public static let shared: AGHapticManager = AGHapticManager()

	private var logger = Logger(subsystem: "com.antokne.agcore", category: "AGHapticManager")

	private var engine: CHHapticEngine?
	private var isEngineRunning: Bool = false
	
	private var registeredHapticPatterns: [String: Data] = [: ]
	
	public init() {
		
	}
	
	public func start() throws {
		
		guard !isEngineRunning else {
			return
		}
		
		engine = try CHHapticEngine()
		engine?.stoppedHandler = { [weak self] reason in
			self?.logger.fault("Stopped for reason: \(reason.rawValue, privacy: .public)")
			self?.isEngineRunning = false
		}
		
		do {
			try engine?.start()
			logger.info("Haptic engine started.")
			self.isEngineRunning = true
		}
		catch {
			logger.info("Failed to start haptic enging \(error).")
			throw error
		}
	}
	
	public func stop() {
		guard isEngineRunning else {
			return
		}
		
		logger.info("Haptic engine stopped.")
		engine?.stop()
	}
	
	public func registerHapticPattern(with name: String, using key: String) throws {
		
		guard let url = Bundle.main.url(forResource: name, withExtension: "ahap") else {
			logger.fault("Invalid url for file named \(name)")
			throw AGHapticError.hapticFileNotFound
		}
		
		do {
			let hapticData = try Data(contentsOf: url)
			registeredHapticPatterns[key] = hapticData
		}
		catch {
			logger.fault("failed to load contents of file \(url)")
			throw AGHapticError.hapticFileNotFound
		}
	}
	
	public func playHapticPatthern(with key: String) throws {
		guard let hapticData = registeredHapticPatterns[key] else {
			logger.fault("haptic with key \(key) is not registered!")
			throw AGHapticError.hapticPatternNotFound
		}

		guard isEngineRunning else {
			logger.fault("haptic engine is not running!")
			throw AGHapticError.hapticEngineNotRunning
		}
		
		try engine?.playPattern(from: hapticData)
	}

}
