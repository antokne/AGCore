//
//  AGFeature.swift
//  
//
//  Created by Ant Gardiner on 17/07/23.
//

import Foundation


public protocol AGFeatureRuleProtocol {
	func enabled(value: Int) -> Bool
}

/// A simple rule always disabled
public class AGFeatureRuleDisabled {
	public init() {}
}

extension AGFeatureRuleDisabled: AGFeatureRuleProtocol {
	public func enabled(value: Int = 0) -> Bool {
		false
	}
}

/// A simple rule enable if value below limit else disable.
public class AGFeatureRuleLimitCount {
	public private(set) var limitValue: Int
	
	public init(value: Int) {
		self.limitValue = value
	}
}

extension AGFeatureRuleLimitCount: AGFeatureRuleProtocol {

	public func enabled(value: Int) -> Bool {
		value < limitValue
	}
}


public protocol AGFeatureProtocol {
	var iconName: String { get }
	var name: String { get }
	var description: String { get }
	var enabled: Bool { get set }
	func enabled(value: Int) -> Bool
	
	var unlockTitle: String { get }
	
	mutating func unlock() async throws -> Bool
}


public class AGFeatureUserDefaults {
	
	public private(set) var iconName: String
	private var defaultsValue: AGUserDefaultBoolValue
	public private(set) var description: String
	private var rule: AGFeatureRuleProtocol
	
	public init(iconName: String, name: String, description: String, rule: AGFeatureRuleProtocol, enabled: Bool = false) {
		self.iconName = iconName
		self.defaultsValue = AGUserDefaultBoolValue(keyName: name)
		self.description = description
		self.rule = rule
		self.defaultsValue.boolValue = enabled
	}
}

extension AGFeatureUserDefaults: AGFeatureProtocol {
	
	public var unlockTitle: String {
		"Unlock"
	}
	
	
	public var name: String {
		return defaultsValue.keyName
	}
	
	public func enabled(value: Int) -> Bool {
		self.enabled || rule.enabled(value: value)
	}
	
	public var enabled: Bool {
		get {
			return defaultsValue.boolValue
		}
		set {
			defaultsValue.boolValue = newValue
		}
	}
	
	public func unlock() async throws -> Bool {
		enabled = true
		return enabled
	}
}



