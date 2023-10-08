//
//  AGSessionConfiguration.swift
//
//
//  Created by Ant Gardiner on 3/10/23.
//

import Foundation

public class AGSessionConfiguration {
	
	static let sessionConfiguartionIdentifier = "com.antokne.agcore.sessionconfiguration"
	
	public static var backgroundSessionConfiguration: URLSessionConfiguration = {
		var configuration = URLSessionConfiguration.background(withIdentifier: AGSessionConfiguration.sessionConfiguartionIdentifier)
		configuration.sessionSendsLaunchEvents = false
		return configuration
	}()
}
