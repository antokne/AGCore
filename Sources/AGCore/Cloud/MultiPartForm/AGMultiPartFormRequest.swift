//
//  AGMultiPartFormRequest.swift
//  
//
//  Created by Antony Gardiner on 29/06/23.
//

import Foundation

struct AGMultiPartFormRequest {
	
	var name: String
	var boundary: String
	var fileURL: URL
	var contentType: String
	var cookie: String?
	
	init(name: String, boundary: String, fileURL: URL, contentType: String, cookie: String? = nil) {
		self.name = name
		self.boundary = boundary
		self.fileURL = fileURL
		self.contentType = contentType
		self.cookie = cookie
	}
	
	func fileData() throws -> Data {
		try Data(contentsOf: fileURL, options: .mappedIfSafe)
	}
	
	var filename: String {
		fileURL.lastPathComponent
	}
	
	func httpBody() throws -> Data {
		var httpBody = Data()
		httpBody.append(contentsOf: "--\(boundary)\r\n".utf8)
		httpBody.append(contentsOf: "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".utf8)
		httpBody.append(contentsOf: "Content-Type: \(contentType)\r\n".utf8)
		httpBody.append(contentsOf: "\r\n".utf8)
		httpBody.append(try fileData())
		httpBody.append(contentsOf: "\r\n".utf8)
		httpBody.append(contentsOf: "--\(boundary)--\r\n".utf8)
		return httpBody
	}
	
	public func asURLRequest(url: URL) throws -> URLRequest {
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		
		if let host = url.host(percentEncoded: false) {
			request.setValue(host, forHTTPHeaderField: "Host")
		}
		
		request.addValue("multipart/form-data; charset=utf-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		
		if let cookie {
			request.setValue(cookie, forHTTPHeaderField: "Cookie")
		}
		
		request.httpBody = try httpBody()
		
		return request
	}
	
}
