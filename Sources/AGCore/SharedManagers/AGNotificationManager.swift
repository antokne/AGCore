//
//  AGNotificationManager.swift
//  
//
//  Created by Ant Gardiner on 24/07/23.
//

import Foundation
import UserNotifications
import NiceNotifications

public class AGNotificationManager {
	
	private var notificationDelegate = AGNotificationDelegate()

	public init() {
		
	}
	
	public func setNotificationDelegate() {
		UNUserNotificationCenter.current().delegate = notificationDelegate
	}

	public func setPresentationOption(options: [String: UNNotificationPresentationOptions]) {
		notificationDelegate.presentationOptions = options
	}

	public func postNotificationNow(
		title: String,
		message: String,
		sound: UNNotificationSound = .default,
		id: String
	) {
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
		scheduleNotification(title: title, message: message, trigger: trigger, id: id)
	}
	
	public func scheduleNotification(
		title: String,
		message: String,
		trigger: UNNotificationTrigger,
		sound: UNNotificationSound = .default,
		id: String
	) {
		let content = UNMutableNotificationContent()
		content.title = title
		content.body = message
		content.sound = sound
		let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
		LocalNotifications.directSchedule(request: request, permissionStrategy: .scheduleIfSystemAllowed)
	}
	
	public func removeNotification(id: String) {
		LocalNotifications.Env.removePendingNotificationRequests([id])
	}
	
	public func getCurrentPendingNotifications() async -> [UNNotificationRequest] {
		await UNUserNotificationCenter.current().pendingNotificationRequests()
	}
	
}


private class AGNotificationDelegate: NSObject {
	var presentationOptions: [String: UNNotificationPresentationOptions] = [: ]
	
	func receivedNotification(info: [AnyHashable : Any]) {
		
	}
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
		let userInfo = response.notification.request.content.userInfo
		receivedNotification(info: userInfo)
		completionHandler()
	}
}
