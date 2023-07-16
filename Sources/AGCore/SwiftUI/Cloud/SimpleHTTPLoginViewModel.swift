//
//  SimpleHTTPLoginViewModel.swift
//  
//
//  Created by Antony Gardiner on 23/06/23.
//

import Foundation
import SwiftUI

enum SimpleHTTPLoginField: Hashable {
    case email
    case password
}

@MainActor
public class SimpleHTTPLoginViewModel: ObservableObject, Identifiable{
	
	@Published var sucess: Bool = true
	
	@Published var siteName: String
	@Published var siteImageName: String? = nil

	@Published var title: String? = "Please enter login details:"
	@Published var email: String = ""
	@Published var password: String = ""
	@Published var showPassword: Bool = false
	
	@Published var showToast = false
	
	var preview: Bool
	
	@Published public private(set) var isAuthenticated: Bool = false
	
	var auth: SimpleHTTPAuth? {
		SimpleHTTPAuth(service: siteName)
	}
	
	public var simpleHTTPService: SimpleHTTPService
	
	var isSignInButtonDisabled: Bool {
		[email, password].contains(where: \.isEmpty)
	}
	
	public init(siteName: String,
				siteImageName: String? = nil,
				title: String? = nil,
				service: SimpleHTTPService,
				preview: Bool = false) {
		self.siteName = siteName
		self.siteImageName = siteImageName
		if title != nil {
			self.title = title
		}
		self.simpleHTTPService = service
		self.preview = preview
		isAuthenticated = auth != nil
	}
	
	public func signIn() {
	
		guard preview == false else {
			print("preview mode")
			saveCredentials(result: "nothing")
			showToast = true
			return
		}
		
		Task {
			do {
				let result = try await simpleHTTPService.login(email: email, password: password)
				
				self.sucess = true
				self.showToast = true
				
				if self.sucess{
					self.saveCredentials(result: result)
				}
			}
			catch {
				self.sucess = false
				self.showToast = true
			}
		}
	}
	
	public func logout() {
		auth?.delete()
		isAuthenticated = false
		showToast = true
	}
	
	public func saveCredentials(result: String?) {
		// save email and password
		var auth = SimpleHTTPAuth(service: siteName, email: email, password: password)
		auth.token = result
		auth.save()
		isAuthenticated = true
	}
}
