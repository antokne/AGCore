//
//  AGPlatformModifiers.swift
//  
//
//  Created by Antony Gardiner on 5/04/23.
//

import SwiftUI

// Allows custom code for swiftui based on platform.
// e.g. .iOS { $0.italic() }
//

@available(macOS 10.15, *)
extension View {
	public func iOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
#if os(iOS)
		return modifier(self)
#else
		return self
#endif
	}
}

@available(macOS 10.15, *)
extension View {
	public func macOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
#if os(macOS)
		return modifier(self)
#else
		return self
#endif
	}
}

@available(macOS 10.15, *)
extension View {
	public func tvOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
#if os(tvOS)
		return modifier(self)
#else
		return self
#endif
	}
}

@available(macOS 10.15, *)
extension View {
	public func watchOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
#if os(watchOS)
		return modifier(self)
#else
		return self
#endif
	}
}
