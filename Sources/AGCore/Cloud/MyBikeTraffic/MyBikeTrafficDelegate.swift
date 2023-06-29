//
//  MyBikeTrafficDelegate.swift
//  
//
//  Created by Antony Gardiner on 29/06/23.
//

import Foundation


public class MyBikeTrafficDelegate: NSObject {
	
}

extension MyBikeTrafficDelegate: URLSessionDelegate {
	
}

extension MyBikeTrafficDelegate: URLSessionTaskDelegate {
	
	public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
		return nil
	}
	
	// Get Challenged twice, 2nd time challenge.protectionSpace.serverTrust is nil, but works!
	@available(iOS 7, *)
	public func urlSession(_ session: URLSession,
						   didReceive challenge: URLAuthenticationChallenge,
						   completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		print("In invalid certificate completion handler")
		if challenge.protectionSpace.serverTrust != nil {
			completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
		} else {
			completionHandler(.useCredential, nil)
		}
	}
}
