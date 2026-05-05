//
//  SimpleHTTPService.swift
//  
//
//  Created by Antony Gardiner on 23/06/23.
//

import Foundation
@preconcurrency import Combine

public protocol AGCloudServiceSiteProtocol: Codable {
	var service: String { get }
	var email: String { get }
	var password: String { get }
	var token: String? { get set }
	
	///Needs to be option so decoding does not fail
	var automaticUpload: Bool? { get set }
	
	init?(service: String)
}

/// Simple struck to save into keychain for http basic auth.
public struct SimpleHTTPAuth: AGCloudServiceSiteProtocol {
	public let service: String
	public let email: String
	public let password: String
	public var token: String?
	
	/// Options so that works with previsou versions without crashing.
	public var automaticUpload: Bool? = true
	
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

/// Simple login sites currently supported
public enum SimpleHTTPLoginType: Sendable {
	case myBikeTraffic
	
	var name: String {
		switch self {
		case .myBikeTraffic:
			return "MyBikeTraffic.com"
		}
	}
}

/// In progress delegate protocol
public protocol AGCloudServiceProtcol {
	func progress(progress: Double)
}

/// tuple containing the token and all headers
public typealias LogInResult = (token: String?, headers: [AnyHashable : Any])

// TODO: - Make MyBikeTraffic it's own thing and this just calls it.
public struct SimpleHTTPService: AGCloudServiceProtcol, Sendable {
	
	public private(set) var loginType: SimpleHTTPLoginType = .myBikeTraffic
	public private(set) var loginURL: URL?
	public private(set) var uploadURL: URL?
	
	private(set) public var uploadProgress = CurrentValueSubject<Double, Never>(Double(0.0))
	public lazy var uploadProgresssPublisher: AnyPublisher<Double, Never> = {
		self.uploadProgress.eraseToAnyPublisher()
	}()
	
	private let logger = AGLogger(subsystem: "com.antokne.core", category: "SimpleHTTPService")

	public func login(email: String, password: String) async throws -> LogInResult {
		
		guard let loginURL else {
			throw SimpleHTTPError.invalidURL
		}
		
		logger.info("login attempt for \(loginType.name)")
		
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
		
		var sessionDelegate: URLSessionDelegate? = UploadServiceDelegate(delegate: self)
		
		switch self.loginType {
		case .myBikeTraffic:
			sessionDelegate = MyBikeTrafficDelegate()
		}
		
		// Use background session to log in.
		let configuration = URLSessionConfiguration.ephemeral //AGSessionConfiguration.backgroundSessionConfiguration
		let session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: nil)

		let (_, response) = try await session.data(for: request, delegate: UploadServiceDelegate(delegate: self) as? URLSessionTaskDelegate)

		switch self.loginType {
		case .myBikeTraffic:
			
			guard let httpResponse = response as? HTTPURLResponse else {
				logger.error("Failed to get HTTP Response")
				throw SimpleHTTPError.authenticationFailed
			}

			guard [200, 302].contains(httpResponse.statusCode) else {
				logger.info("login attempt failed did not get a 302 or 200 status code got \(httpResponse.statusCode) instead.")
				throw SimpleHTTPError.invalidServerResponse
			}
			
			let cookie = httpResponse.value(forHTTPHeaderField: "Set-Cookie")
			let result = cookie?.split(separator: ";").first
			
			guard let result else {
				logger.error("login attempt failed got a status code did not get a cookie.")
				throw SimpleHTTPError.authenticationFailed
			}

			logger.debug("logged in with cookie: \(result)")

			return (String(result), httpResponse.allHeaderFields)
		}
	}
	
	/// Attempts to upload a fit file and returns the id of the uploaded file if sucessful
	/// - Parameters:
	///   - fileURL: url of the file to upload
	///   - auth: auth details to use in upload
	/// - Returns: the id on the file uploaded on the server that can be used in linking
	public func upload(fileURL: URL,
					   using auth: AGCloudServiceSiteProtocol,
					   metadata: AGBackgroundUploadMetadata? = nil) async throws -> String {

		logger.info("upload file \(fileURL)")

		guard let uploadURL else {
			logger.fault("Did not get a file")
			throw SimpleHTTPError.invalidURL
		}

		// if nil then try the one we currently have
		switch self.loginType {
		case .myBikeTraffic:

			// 1. login (foreground / ephemeral session — only the upload step
			// is moved to the background session).
			let loginResult = try await login(email: auth.email, password: auth.password)
			var result = loginResult.token
			if result == nil {
				logger.warning("Trying to use saved cookie, this may fail.")
				result = auth.token
			}

			guard let cookie = result else {
				logger.warning("Cookie is still nil can't continue.")
				throw SimpleHTTPError.authenticationFailed
			}

			let contentType = "application/vnd.ant.fit"
			let multiPartFormRequest = AGMultiPartFormRequest(name: "fitfile",
															  boundary: "__X_BOUNDARY__",
															  fileURL: fileURL,
															  contentType: contentType,
															  cookie: cookie)

			// uploadTask(with:fromFile:) ignores request.httpBody and sends the
			// file contents as-is. We need the full multipart envelope (boundary
			// headers + "fitfile" field) to be the body, so write it to a temp
			// file and pass that to the background session instead.
			let multipartBody = try multiPartFormRequest.httpBody()
			let tempFileURL = FileManager.default.temporaryDirectory
				.appending(path: UUID().uuidString + ".multipart")
			try multipartBody.write(to: tempFileURL)

			// Build a headers-only request — fromFile: supplies the body.
			var uploadRequest = URLRequest(url: uploadURL)
			uploadRequest.httpMethod = "POST"
			uploadRequest.allHTTPHeaderFields = try multiPartFormRequest.asURLRequest(url: uploadURL).allHTTPHeaderFields

			// 2. Upload — handed off to the shared background URLSession so
			// the transfer survives suspension / termination.
			let uploadMetadata = metadata ?? AGBackgroundUploadMetadata(
				activityObjectIDURI: "",
				shareSiteName: loginType.name,
				fileURLString: fileURL.absoluteString)

			logger.info("Handing upload to background session site=\(loginType.name) file=\(fileURL.lastPathComponent) bytes=\(multipartBody.count)")

			let (data, response) = try await AGBackgroundUploadSession.shared.upload(
				fileURL: tempFileURL,
				request: uploadRequest,
				metadata: uploadMetadata)

			try? FileManager.default.removeItem(at: tempFileURL)

			logger.info("Background upload returned status=\(response.statusCode) bytes=\(data.count)")

			// Cookie-staleness handling: a 401 or a 302 redirect to the
			// login page indicates the PHP session expired between login
			// and upload (common after iOS-initiated relaunch). Surface
			// `authenticationFailed` so the caller can keep status as
			// `.inProgress` and retry on the next BG fire with a fresh
			// login.
			if response.statusCode == 401 || response.statusCode == 302 {
				logger.warning("Upload returned \(response.statusCode) — cookie likely stale.")
				throw SimpleHTTPError.authenticationFailed
			}

			return try Self.parseMyBikeTrafficUploadResponse(data: data)
		}
	}

	/// Decodes a MyBikeTraffic upload response body into a ride id.
	/// Exposed so the background-session relaunch handler can reuse the
	/// same parsing logic when iOS delivers a completion outside of an
	/// `await session.upload(...)` call.
	public static func parseMyBikeTrafficUploadResponse(data: Data) throws -> String {
		let logger = AGLogger(subsystem: "com.antokne.core", category: "SimpleHTTPService")
		var mbtResponse: MyBikeTrafficUploadResponse? = nil
		do {
			mbtResponse = try data.decodeData()
		}
		catch {
			logger.warning("Decoding json data failed \(String(data: data, encoding: .utf8) ?? "?")")

			if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
			   let error = jsonObject["err"] as? String {
				logger.fault("Failed to get error from parsing json")
				throw SimpleHTTPError.serverError(error: error)
			}
		}

		if let dup = mbtResponse?.dup {
			logger.info("Got dup result \(dup).")
			return dup
		}
		if let error = mbtResponse?.err {
			logger.warning("Server error \(error)")
			throw SimpleHTTPError.serverError(error: error)
		}
		guard let rideId = mbtResponse?.ride?.id else {
			logger.error("failed to upload file.")
			throw SimpleHTTPError.uploadFailed
		}

		logger.info("File uploaded got ride id \(rideId).")
		return String(rideId)
	}
	
	public func progress(progress: Double) {
		uploadProgress.value = progress
	}
}

extension SimpleHTTPService {
	
	public static let myBikeTrafficService = SimpleHTTPService(loginType: .myBikeTraffic,
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
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		
	}
}
