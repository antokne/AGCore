//
//  NSView+Constraints.swift
//
//  Created by Kostiantyn Teterin on 07.05.17.
//  Copyright © 2017 Kostiantyn Teterin. All rights reserved.
//
#if os(macOS)

import Cocoa

public extension NSView {
	struct ConstraintBuilder {
		var dstView: NSView
		let srcView: NSView
		
		init(from srcView: NSView, to dstView: NSView) {
			self.srcView = srcView
			self.dstView = dstView
		}
		
		// MARK: - Constraints to superview
		
		@discardableResult public func max(_ offset: CGFloat = 0) -> ConstraintBuilder {
			srcView.topAnchor.constraint(equalTo: dstView.topAnchor, constant: offset).isActive = true
			return self
		}
		
		@discardableResult public func min(_ offset: CGFloat = 0) -> ConstraintBuilder {
			srcView.bottomAnchor.constraint(equalTo: dstView.bottomAnchor, constant: offset).isActive = true
			return self
		}

		@discardableResult public func bottomGreaterThanEqualTo(_ offset: CGFloat = 0) -> ConstraintBuilder {
			srcView.bottomAnchor.constraint(greaterThanOrEqualTo: dstView.bottomAnchor, constant: offset).isActive = true
			return self
		}
		
		@discardableResult public func left(_ offset: CGFloat = 0) -> ConstraintBuilder {
			srcView.leftAnchor.constraint(equalTo: dstView.leftAnchor, constant: offset).isActive = true
			return self
		}
		
		@discardableResult public func right(_ offset: CGFloat = 0) -> ConstraintBuilder {
			srcView.rightAnchor.constraint(equalTo: dstView.rightAnchor, constant: offset).isActive = true
			return self
		}
		
		@discardableResult public func leading(_ offset: CGFloat = 0) -> ConstraintBuilder {
			srcView.leadingAnchor.constraint(equalTo: dstView.leadingAnchor, constant: offset).isActive = true
			return self
		}
		
		@discardableResult public func trailing(_ offset: CGFloat = 0) -> ConstraintBuilder {
			srcView.trailingAnchor.constraint(equalTo: dstView.trailingAnchor, constant: offset).isActive = true
			return self
		}
		
		@discardableResult public func centerX(_ value: CGFloat = 0) -> ConstraintBuilder {
			srcView.centerXAnchor.constraint(equalTo: dstView.centerXAnchor, constant: value).isActive = true
			return self
		}
		
		@discardableResult public func centerY(_ value: CGFloat = 0) -> ConstraintBuilder {
			srcView.centerYAnchor.constraint(equalTo: dstView.centerYAnchor, constant: value).isActive = true
			return self
		}
		
		// MARK: - Size constraints
		
		@discardableResult public func width(_ value: CGFloat) -> ConstraintBuilder {
			srcView.widthAnchor.constraint(equalToConstant: value).isActive = true
			return self
		}
		
		@discardableResult public func height(_ value: CGFloat, priority: NSLayoutConstraint.Priority = .required) -> ConstraintBuilder {
			let constraint = srcView.heightAnchor.constraint(equalToConstant: value)
			constraint.priority = priority
			constraint.isActive = true
			return self
		}

		@discardableResult public func heightGreaterThanEqualTo(_ value: CGFloat) -> ConstraintBuilder {
			srcView.heightAnchor.constraint(greaterThanOrEqualToConstant: value).isActive = true
			return self
		}
		
		// MARK: - Constraints to custom anchors
		
		@discardableResult public func leftTo(anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0) -> ConstraintBuilder {
			srcView.leftAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
			return self
		}
		
		@discardableResult public func rightTo(anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0) -> ConstraintBuilder {
			srcView.rightAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
			return self
		}
		
		@discardableResult public func leadingTo(anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0) -> ConstraintBuilder {
			srcView.leadingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
			return self
		}
		
		@discardableResult public func trailingTo(anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0) -> ConstraintBuilder {
			srcView.trailingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
			return self
		}
		
		@discardableResult public func topTo(anchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat = 0) -> ConstraintBuilder {
			srcView.topAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
			return self
		}
		
		@discardableResult public func bottomTo(anchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat = 0) -> ConstraintBuilder {
			srcView.bottomAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
			return self
		}
		
		@discardableResult public func heightTo(anchor: NSLayoutDimension, constant: CGFloat = 0, multiplier: CGFloat = 1) -> ConstraintBuilder {
			let constraint = srcView.heightAnchor.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
			constraint.priority = NSLayoutConstraint.Priority.defaultHigh
			constraint.isActive = true
			return self
		}
		
		@discardableResult public func widthTo(anchor: NSLayoutDimension, constant: CGFloat = 0) -> ConstraintBuilder {
			srcView.widthAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
			return self
		}
		
		@discardableResult public func centerXTo(anchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat = 0) -> ConstraintBuilder {
			srcView.centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
			return self
		}
		
		@discardableResult public func centerYTo(anchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat = 0) -> ConstraintBuilder {
			srcView.centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
			return self
		}
	}
	
	// MARK: - Builder
	
	var createConstraints: ConstraintBuilder {
		if superview == nil {
			fatalError("ConstraintBuilder: superview is nil for \(self)")
		}
		self.translatesAutoresizingMaskIntoConstraints = false
		return ConstraintBuilder(from: self, to: superview!)
	}
}
#endif
