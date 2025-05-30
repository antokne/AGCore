//
//  NavigationStackModifier.swift
//  AGCore
//
//  Created by Ant Gardiner on 23/03/2025.
//

import SwiftUI

struct NavigationStackModifier: ViewModifier {
    func body(content: Content) -> some View {
        NavigationStack {
            content
        }
    }
}

extension View {
    public func embedInNavigationStack() -> some View {
        modifier(NavigationStackModifier())
    }
}
