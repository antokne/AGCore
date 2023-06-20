//
//  AGMailView.swift
//  
//
//  Created by Antony Gardiner on 19/06/23.
//

import SwiftUI
import UIKit
import MessageUI

public struct AGMailAttachment {
	var url: URL
	var mimeType: String
	var fileName: String
	
	public init(url: URL, mimeType: String, fileName: String) {
		self.url = url
		self.mimeType = mimeType
		self.fileName = fileName
	}
}

public struct AGMailView: UIViewControllerRepresentable {
	
	@Environment(\.presentationMode) var presentation
	@Binding var result: Result<MFMailComposeResult, Error>?
	
	private var mailTo: String
	private var subject: String
	private var body: String?

	private var attachments: [AGMailAttachment] = []

	public init(result: Binding<Result<MFMailComposeResult, Error>?>,
				mailTo: String,
				subject: String,
				body: String? = nil,
				attachments: [AGMailAttachment] = []) {
		self._result = result
		self.mailTo = mailTo
		self.subject = subject
		self.body = body
		self.attachments = attachments
	}
	
	public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
		
		@Binding var presentation: PresentationMode
		@Binding var result: Result<MFMailComposeResult, Error>?
		
		public init(presentation: Binding<PresentationMode>,
			 result: Binding<Result<MFMailComposeResult, Error>?>) {
			_presentation = presentation
			_result = result
		}
		
		public func mailComposeController(_ controller: MFMailComposeViewController,
								   didFinishWith result: MFMailComposeResult,
								   error: Error?) {
			defer {
				$presentation.wrappedValue.dismiss()
			}
			guard error == nil else {
				self.result = .failure(error!)
				return
			}
			self.result = .success(result)
		}
	}
	
	public func makeCoordinator() -> Coordinator {
		return Coordinator(presentation: presentation,
						   result: $result)
	}
	
	public func makeUIViewController(context: UIViewControllerRepresentableContext<AGMailView>) -> MFMailComposeViewController {
		let vc = MFMailComposeViewController()
		vc.mailComposeDelegate = context.coordinator
		vc.setToRecipients([mailTo])
		vc.setSubject(subject)
		if let body {
			vc.setMessageBody(body, isHTML: false)
		}
		
		for attachment in attachments {
			if let data = try? Data(contentsOf: attachment.url) {
				vc.addAttachmentData(data, mimeType: attachment.mimeType, fileName: attachment.fileName)
			}
		}
		
		return vc
	}
	
	public func updateUIViewController(_ uiViewController: MFMailComposeViewController,
								context: UIViewControllerRepresentableContext<AGMailView>) {
		
	}
}
