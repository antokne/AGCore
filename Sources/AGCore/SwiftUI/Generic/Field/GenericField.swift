//
//  GenericField.swift
//  RaceWeight
//
//  Created by Antony Gardiner on 8/03/23.
//

import Foundation
import SwiftUI

public protocol GenericFieldTypeProtocol {
	func name() -> String
	static var notSelected: GenericFieldValue { get }
	static func allFields() -> [GenericFieldValue]
	static func allValues() -> [String]
	func field() -> GenericFieldValue
}

public extension GenericFieldTypeProtocol {
	static var notSelected: GenericFieldValue {
		GenericFieldValue(key: -1 , value: "Select")
	}
	static func allValues() -> [String] {
		let fields = allFields()
		return fields.map { $0.value }
	}
}

public enum GenericFieldValidViewModel {
	case add
	case edit
	case view
	
	public static let all: [GenericFieldValidViewModel] = [.add, .edit, .view]
	public static let addOnlly: [GenericFieldValidViewModel] = [.add]
	public static let editView: [GenericFieldValidViewModel] = [.edit, .view]
}

public class GenericFieldValue: Identifiable, Hashable {
	
	public var id: GenericFieldValue { self }
	public var key: Int
	public var value: String
	public init(key: Int, value: String) {
		self.key = key
		self.value = value
	}
	
	public static func == (lhs: GenericFieldValue, rhs: GenericFieldValue) -> Bool {
		return lhs.key == rhs.key
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(key)
	}
}

public class GenericField: ObservableObject {
	public var key: String = UUID().uuidString
	public var title: String
	public var value: String
	
	public var unit: Measurement<Dimension>?
	
	public var validFields: [GenericFieldValue] = []
	public var selectedFieldValue: GenericFieldValue = GenericFieldValue(key: -1, value: "Select")
	
	public var validFieldValues: [String] = []
	
	public var validViewModes: [GenericFieldValidViewModel]
	
	public init(key: String? = nil, title: String, value: String, unit: Measurement<Dimension>? = nil, validFields: [GenericFieldValue] = [], selectedValue: GenericFieldValue? = nil, validFieldValues: [String]? = nil, validViewModes: [GenericFieldValidViewModel]) {
		if let key {
			self.key = key
		}
		self.title = title
		self.value = value
		self.unit = unit
		self.validFields = validFields
		if let selectedValue {
			self.selectedFieldValue = selectedValue
		}
		if let validFieldValues {
			self.validFieldValues = validFieldValues
		}
		self.validViewModes = validViewModes
	}
}
