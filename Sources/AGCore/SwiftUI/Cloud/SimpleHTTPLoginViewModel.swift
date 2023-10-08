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

public class SimpleHTTPLoginViewModel: ObservableObject, Identifiable {
	
	@Published var success: Bool = true
	
	@Published var siteName: String
	@Published var siteImageName: String? = nil

	@Published var title: String? = "Please enter login details:"
	@Published var email: String = ""
	@Published var password: String = ""
	@Published var showPassword: Bool = false
	
	@Published var showToast = false
	
	@Published var automaticUpload = true {
		didSet {
			automaticUploadChanged()
		}
	}
	
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
		automaticUpload = auth?.automaticUpload ?? true
	}
	
	public func signIn() {
	
		guard preview == false else {
			print("preview mode")
			saveCredentials(result: "nothing")
			showToast = true
			return
		}
		
		Task { @MainActor in
			do {
				let loginResult = try await simpleHTTPService.login(email: email, password: password)
				let result = loginResult.token
				
				self.success = true
				self.showToast = true
				
				if self.success{
					self.saveCredentials(result: result)
				}
			}
			catch {
				self.success = false
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
	
	private func automaticUploadChanged() {
		guard var auth = self.auth else {
			return
		}
		auth.automaticUpload = automaticUpload
		auth.save()
	}
}
