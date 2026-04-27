//
//  AGSessionConfiguration.swift
//
//
//  Created by Ant Gardiner on 3/10/23.
//

import Foundation

public enum AGSessionConfiguration {

	public static let backgroundUploadIdentifier = "com.antokne.veloscope.upload"

	public static var backgroundSessionConfiguration: URLSessionConfiguration = {
		let configuration = URLSessionConfiguration.background(withIdentifier: AGSessionConfiguration.backgroundUploadIdentifier)
		configuration.sessionSendsLaunchEvents = true
		configuration.isDiscretionary = false
		configuration.allowsCellularAccess = true
		configuration.waitsForConnectivity = true
		return configuration
	}()
}
