//
//  AGNotificationManager.swift
//  
//
//  Created by Ant Gardiner on 24/07/23.
//

import Foundation
import UserNotifications


public class AGNotificationManager {
	
	public static let shared: AGNotificationManager = AGNotificationManager()

	private var notificationDelegate = AGNotificationDelegate()

	public init() {
		
	}
	
	public func setNotificationDelegate() {
		UNUserNotificationCenter.current().delegate = notificationDelegate
	}

	public func setPresentationOption(options: [String: UNNotificationPresentationOptions]) {
		notificationDelegate.presentationOptions = options
	}
}


private class AGNotificationDelegate: NSObject {
	var presentationOptions: [String: UNNotificationPresentationOptions] = [: ]
}

extension AGNotificationDelegate: UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
		
		// got a notification do we have an option for this one?
		if let presentOption =  presentationOptions[notification.request.identifier] {
			return presentOption
		}
		
		// Default is to do nothing...
		return []
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		completionHandler()
	}
}
