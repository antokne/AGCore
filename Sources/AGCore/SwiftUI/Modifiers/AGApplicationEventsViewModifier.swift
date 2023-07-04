//
//  AGApplicationEventsViewModifier.swift
//  
//
//  Created by Ant Gardiner on 4/07/23.
//

import SwiftUI

#if os(iOS)
public struct AGApplicationEventsViewModifier: ViewModifier {
    let action: () -> Void
    
    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                action()
            }
    }
}

extension View {
    
    /// Notification sent when application will enter the foreground
    /// - Parameter action: action to call when event occurs.
    /// - Returns: A view that triggers on event
    public func willEnterForeground(perform action: @escaping () -> Void) -> some View {
        self.modifier(AGApplicationEventsViewModifier(action: action))
    }
}
#endif
