//
//  AGCoreData+Extensions.swift
//  
//
//  Created by Antony Gardiner on 5/05/23.
//

import Foundation
import CoreData

public func == <T>(lhs: KeyPath<some NSManagedObject, T>, rhs: T) -> NSPredicate {
	NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: lhs),
						  rightExpression: NSExpression(forConstantValue: rhs), modifier: .direct, type: .equalTo)
}

public func inPredicate<T>(for object: T, in set: KeyPath<some NSManagedObject, NSSet?>) -> NSPredicate {
	NSComparisonPredicate(leftExpression: NSExpression(forConstantValue: object),
						  rightExpression: NSExpression(forKeyPath: set), modifier: .direct, type: .in)
}

extension NSPredicate {


	public static func && (a: NSPredicate, b: NSPredicate) -> NSPredicate {
		NSCompoundPredicate(andPredicateWithSubpredicates: [a, b])
	}
	public static func || (a: NSPredicate, b: NSPredicate) -> NSPredicate {
		NSCompoundPredicate(orPredicateWithSubpredicates: [a, b])
	}
	public static prefix func ! (a: NSPredicate) -> NSPredicate {
		NSCompoundPredicate(notPredicateWithSubpredicate: a)
	}
}
