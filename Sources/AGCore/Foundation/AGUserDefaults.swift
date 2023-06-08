//
//  AGUserDefaults.swift
//  Gruppo
//
//  Created by Antony Gardiner on 5/04/23.
//

import Foundation


public struct AGUserDefaultLastSyncDate {
	
	static let LastSyncKey = "-last-sync-time-interval"
	
	var name: String
	
	var defaultFromDate: Date
	
	public init(name: String, defaultFromDate: Date = Date(timeIntervalSinceReferenceDate: 0.0)) {
		self.name = name
		self.defaultFromDate = defaultFromDate
	}
	
	private var key: String {
		name.appending(AGUserDefaultLastSyncDate.LastSyncKey)
	}
	
	public var lastSyncDate: Date {
		get {
			var lastSyncTimeInterval: TimeInterval = UserDefaults.standard.double(forKey: key)
			if lastSyncTimeInterval == 0 {
				lastSyncTimeInterval = defaultFromDate.timeIntervalSinceReferenceDate
			}
			let date = Date(timeIntervalSinceReferenceDate: lastSyncTimeInterval)
			return date
		}
		set {
			UserDefaults.standard.set(newValue.timeIntervalSinceReferenceDate, forKey: key)
		}
	}
}

public struct AGUserDefaultStringValue {
	var keyName: String
	var defaultValue: String
	
	public init(keyName: String, defaultValue: String = "") {
		self.keyName = keyName
		self.defaultValue = defaultValue
	}
	
	public var stringValue: String {
		get {
			let value = UserDefaults.standard.string(forKey: keyName)
			return value ?? defaultValue
		}
		set {
			UserDefaults.standard.set(newValue, forKey: keyName)
		}
	}
}

public struct AGUserDefaultBoolValue {
	var keyName: String
	
	public init(keyName: String) {
		self.keyName = keyName
	}
	
	public var boolValue: Bool {
		get {
			let value = UserDefaults.standard.bool(forKey: keyName)
			return value
		}
		set {
			UserDefaults.standard.set(newValue, forKey: keyName)
		}
	}
}


public struct AGUserDefaultDoubleValue {
	var keyName: String
	
	public init(keyName: String, defaultValue: Double) {
		self.keyName = keyName
		UserDefaults.standard.register(defaults: [keyName: defaultValue])
	}
	
	public var doubleValue: Double {
		get {
			let value = UserDefaults.standard.double(forKey: keyName)
			return value
		}
		set {
			UserDefaults.standard.set(newValue, forKey: keyName)
		}
	}
}
