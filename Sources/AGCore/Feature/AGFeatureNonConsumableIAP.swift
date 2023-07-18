//
//  AGFeatureNonConsumableIAP.swift
//  
//
//  Created by Ant Gardiner on 18/07/23.
//

import Foundation
import StoreKit
import OSLog

public class AGFeatureNonConsumableIAP {
	
	public private(set) var iconName: String
	public private(set) var defaultName: String
	public private(set) var productId: String
	public private(set) var description: String
	private var rule: AGFeatureRuleProtocol
	
	public var logger = Logger(subsystem: "com.antokne.core", category: "AGFeatureNonConsumableIAP")


	/// A defaults "cache" value to use before product is avaialble
	private var defaultsValue: AGUserDefaultBoolValue

	public var product: Product?
	{
		didSet {
			updateDefaultValue()
		}
	}
	
	public var transaction: Transaction?
	
	
	public init(iconName: String, defaultName: String, productId: String, description: String, rule: AGFeatureRuleProtocol) {
		self.iconName = iconName
		self.defaultName = defaultName
		self.productId = productId
		self.defaultsValue = AGUserDefaultBoolValue(keyName: productId)
		self.description = description
		self.rule = rule
	}
	
	private func updateDefaultValue() {
		// set default value from product value.
		print("have a product update default value")
	}
	
}


extension AGFeatureNonConsumableIAP: AGFeatureProtocol {
	
	public var unlockTitle: String {
		"Unlock for " + (product?.displayPrice ?? "")
	}
	
	
	public var name: String {
		product?.displayName ?? defaultName
	}
	
	public var enabled: Bool {
		get {
			transaction != nil
		}
		set {
			// makes no sense here.
		}
	}
	
	public func enabled(value: Int) -> Bool {
		self.enabled || rule.enabled(value: value)
	}
	
	public func unlock() async throws -> Bool {

		guard let product else {
			logger.error("no product cannot make a purchase yet!")
			return false
		}
		
		let result = try await product.purchase()
		switch result {
		case .success(.verified(let transaction)):
			self.transaction = transaction
			await transaction.finish()
			return true
		default:
			return false
		}
	}
	
}