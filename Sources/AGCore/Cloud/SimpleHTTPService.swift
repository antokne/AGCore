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
	static let simpleAuthKey = "simepleAuth" // !!!
	
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
	case uploadFailed
	case serverError(error: String)
}

public enum SimpleHTTPLoginType {
	case myBikeTrafficCookie
}

public protocol AGCloudServiceProtcol {
	func progress(progress: Double)
}


// TODO: - Make MyBikeTraffic it's own thing and this just calls it.
public struct SimpleHTTPService: AGCloudServiceProtcol {
	
	var loginType: SimpleHTTPLoginType = .myBikeTrafficCookie
	var loginURL: URL?
	var uploadURL: URL?
	
	private(set) public var uploadProgress = CurrentValueSubject<Double, Never>(Double(0.0))
	public lazy var uploadProgresssPublisher: AnyPublisher<Double, Never> = {
		self.uploadProgress.eraseToAnyPublisher()
	}()

	public func login(email: String, password: String) async throws -> String? {
		
		guard let loginURL else {
			throw SimpleHTTPError.invalidURL
		}
		
		var request = URLRequest(url: loginURL)
		request.httpMethod = "POST"
		request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
		if let host = loginURL.host(percentEncoded: false) {
			request.addValue(host, forHTTPHeaderField: "Host")
		}

		let bodyParameters = [
			"email": email,
			"password": password,
		]
		let bodyString: String = bodyParameters.queryParameters
		request.httpBody = bodyString.data(using: .utf8, allowLossyConversion: true)
		request.httpShouldHandleCookies = false
		
		var sessionDelegate: URLSessionDelegate? = nil
		
		switch self.loginType {
		case .myBikeTrafficCookie:
			sessionDelegate = MyBikeTrafficDelegate()
		}
		
		let configuration = URLSessionConfiguration.default
		let session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: nil)
		
		let (_, response) = try await session.data(for: request)
		
		switch self.loginType {
		case .myBikeTrafficCookie:
			
			guard let httpResponse = response as? HTTPURLResponse,
				  httpResponse.statusCode == 302 else {
				throw SimpleHTTPError.invalidServerResponse
			}
			
			let cookie = httpResponse.value(forHTTPHeaderField: "Set-Cookie")
			let result = cookie?.split(separator: ";").first
			
			guard let result else {
				throw SimpleHTTPError.authenticationFailed
			}
			
			return String(result)
		}
	}
	
	/// Attempts to upload a fit file and returns the id of the uploaded file if sucessful
	/// - Parameters:
	///   - fileURL: url of the file to upload
	///   - auth: auth details to use in upload
	/// - Returns: the id on the file uploaded on the server that can be used in linking
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
			
			let contentType = "application/vnd.ant.fit"
			let multiPartFormRequest = AGMultiPartFormRequest(name: "fitfile",
															  boundary: "__X_BOUNDARY__",
															  fileURL: fileURL,
															  contentType: contentType,
															  cookie: cookie)
			
			let uploadRequest = try multiPartFormRequest.asURLRequest(url: uploadURL)

			let delegate = UploadServiceDelegate(delegate: self) as? URLSessionTaskDelegate
			let (data, response) = try await URLSession.shared.data(for: uploadRequest, delegate: delegate)
			
			print("\(data)")
			print("\(response)")
			
			var mbtResponse: MyBikeTrafficUploadResponse? = nil
			do {
				mbtResponse = try data.decodeData()
			}
			catch {
				// IF we get a decoding error probably some error.
				if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
				let error = jsonObject["err"] as? String{
					throw SimpleHTTPError.serverError(error: error)
				}
			}
			
			if let dup = mbtResponse?.dup {
				// already uploaded is not an error.
				return dup
			}
			if let error = mbtResponse?.err {
				throw SimpleHTTPError.serverError(error: error)
			}
			guard let rideId = mbtResponse?.ride?.id else {
				throw SimpleHTTPError.uploadFailed
			}
			
			return String(rideId)
		}
	}
	
	public func progress(progress: Double) {
		uploadProgress.value = progress
	}
}

extension SimpleHTTPService {
	
	public static let myBikeTrafficService = SimpleHTTPService(loginType: .myBikeTrafficCookie,
															   loginURL: URL(string: "https://www.mybiketraffic.com/auth/login"),
															   uploadURL: URL(string: "https://www.mybiketraffic.com/rides/upload"))
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
