//
//  SimpleHTTPService.swift
//  
//
//  Created by Antony Gardiner on 23/06/23.
//

import Foundation
import Combine

public protocol AGCloudServiceSiteProtocol: Codable {
	var service: String { get }
	var email: String { get }
	var password: String { get }
	var token: String? { get set }
	init?(service: String)
}

/// Simple struck to save into keychain for http basic auth.
public struct SimpleHTTPAuth: AGCloudServiceSiteProtocol {
	public let service: String
	public let email: String
	public let password: String
	public var token: String?
	static let simpleAuthKey = "simepleAuth"
	
	init(service: String, email: String, password: String) {
		self.service = service
		self.email = email
		self.password = password
	}
	
	public init?(service: String) {
		guard let auth = KeychainHelper.standard.read(service: service,
									 account: SimpleHTTPAuth.simpleAuthKey,
													  type: SimpleHTTPAuth.self) else {
			return nil
		}
		self = auth
	}
	
	func save() {
		KeychainHelper.standard.save(self,
									 service: service,
									 account: SimpleHTTPAuth.simpleAuthKey)
	}
	
	func delete() {
		KeychainHelper.standard.delete(service: service,
									   account: SimpleHTTPAuth.simpleAuthKey)
	}
}

public enum SimpleHTTPError: Error {
	case invalidServerResponse
	case invalidEmailPassword
	case invalidURL
	case authenticationFailed
	case noKnownService
}

public enum SimpleHTTPLoginCheck {
	case myBikeTrafficCookie
	
	var key: String {
		switch self {
		case .myBikeTrafficCookie:
			return "Cookie"
		}
	}
}

public protocol AGCloudServiceProtcol {
	func progress(progress: Double)
}


// TODO: - Make this conform to a protocol
public struct SimpleHTTPService: AGCloudServiceProtcol {
	
	var loginType: SimpleHTTPLoginCheck = .myBikeTrafficCookie
	var loginURL: URL?
	var uploadURL: URL?
	
	private(set) public var uploadProgress = CurrentValueSubject<Double, Never>(Double(0.0))
	public lazy var uploadProgresssPublisher: AnyPublisher<Double, Never> = {
		self.uploadProgress.eraseToAnyPublisher()
	}()

	public func login(email: String, password: String) async throws -> String? {
		
		let loginString = "\(email):\(password)"
		
		guard let loginData = loginString.data(using: String.Encoding.utf8) else {
			throw SimpleHTTPError.invalidEmailPassword
		}
		let base64LoginString = loginData.base64EncodedString()
		
		guard let loginURL else {
			throw SimpleHTTPError.invalidURL
		}
		
		var request = URLRequest(url: loginURL)
		request.httpMethod = "GET"
		request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
		
		let (_, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse,
			  httpResponse.statusCode == 200 else {
			throw SimpleHTTPError.invalidServerResponse
		}
		
		switch self.loginType {
		case .myBikeTrafficCookie:
			let cookie = httpResponse.value(forHTTPHeaderField: "Set-Cookie")
			let result = cookie?.split(separator: ";").first
			//let result2 = result?.split(separator: "=")
//			let token = result //2?.last
			
			guard let result else {
				throw SimpleHTTPError.authenticationFailed
			}
			
			return String(result)
		}
	}
	
	public func upload(fileURL: URL, using auth: AGCloudServiceSiteProtocol) async throws -> String {
		
		guard let uploadURL else {
			throw SimpleHTTPError.invalidURL
		}
		
		// 1. login.
		var result = try await login(email: auth.email, password: auth.password)
		
		// if nil then try the one we currently have
		switch self.loginType {
		case .myBikeTrafficCookie:
			if result == nil {
				result = auth.token
			}
			guard let cookie = result else {
				throw SimpleHTTPError.authenticationFailed
			}
			

			
			var uploadRequest = URLRequest(url: uploadURL)
			uploadRequest.httpMethod = "POST"
			uploadRequest.setValue("www.mybiketraffic.com", forHTTPHeaderField: "Host")
			uploadRequest.setValue(cookie, forHTTPHeaderField: loginType.key)
			uploadRequest.httpShouldHandleCookies = true
			
			
			let delegate = UploadServiceDelegate(delegate: self) as? URLSessionTaskDelegate
			let (data, response) = try await URLSession.shared.upload(for: uploadRequest,
																	  fromFile: fileURL,
																	  delegate: delegate)
			
			print("\(data)")
			print("\(response)")

			// TODO: Extract the id if ok otherwise return an error
			return "unknown id"
		}
	}
	
	public func progress(progress: Double) {
		uploadProgress.value = progress
	}
}

extension SimpleHTTPService {
	
	public static let myBikeTrafficService = SimpleHTTPService(loginType: .myBikeTrafficCookie,
															   loginURL: URL(string: "https://www.mybiketraffic.com/auth/login"),
															   uploadURL: URL(string: "https://www.mybiketraffic.com/import"))
}


class UploadServiceDelegate: NSObject, URLSessionDelegate {
	
	var delegate: AGCloudServiceProtcol?
	
	init(delegate: AGCloudServiceProtcol? = nil) {
		self.delegate = delegate
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
		
		delegate?.progress(progress: Double(totalBytesSent) / Double(totalBytesExpectedToSend))
	}
}
