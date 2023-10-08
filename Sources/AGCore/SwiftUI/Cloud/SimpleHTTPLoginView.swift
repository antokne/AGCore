//
//  SimpleHTTPLoginView.swift
//  
//
//  Created by Antony Gardiner on 23/06/23.
//

import SwiftUI
import AlertToast

struct SimpleHTTPLoginDetailView: View {
	@Environment(\.presentationMode) var presentationMode

	@ObservedObject var viewModel: SimpleHTTPLoginViewModel

	@FocusState private var focusedField: SimpleHTTPLoginField?
	
	public var body: some View {
		VStack() {
			if let title = viewModel.title {
				Text(title)
					.font(.title3)
					.padding(10)
					.bold()
			}
			TextField("email",
					  text: $viewModel.email ,
					  prompt: Text("email").foregroundColor(.accentColor)
			)
			.textContentType(.emailAddress)
			.keyboardType(.emailAddress)
			.focused($focusedField, equals: .email)
			.padding(10)
			.overlay {
				RoundedRectangle(cornerRadius: 10)
					.stroke(Color.accentColor, lineWidth: 2)
			}
			.padding(.horizontal)
			
			HStack {
				Group {
					if viewModel.showPassword {
						TextField("Password", // how to create a secure text field
								  text: $viewModel.password,
								  prompt: Text("Password").foregroundColor(.accentColor)) // How to change the color of the TextField Placeholder
						.textContentType(.password)
						.focused($focusedField, equals: .password)
					} else {
						SecureField("Password", // how to create a secure text field
									text: $viewModel.password,
									prompt: Text("Password").foregroundColor(.accentColor)) // How to change the color of the TextField Placeholder
						.textContentType(.password)
						.focused($focusedField, equals: .password)
					}
				}
				.padding(10)
				.overlay() {
					RoundedRectangle(cornerRadius: 10)
						.stroke(Color.accentColor, lineWidth: 2) // How to add rounded corner to a TextField and change it colour
					
				}
				.overlay(alignment: .trailing) {
					Button {
						viewModel.showPassword.toggle()
					} label: {
						Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
							.foregroundColor(.accentColor) // how to change image based in a State variable
					}
					.padding(5)
				}
			}.padding(.horizontal)
			
			Spacer()
			
			VStack {
				
				Button {
					viewModel.signIn()
					focusedField = nil
				} label: {
					Text("Log In")
						.frame(maxWidth: .infinity) // how to make a button fill all the space available horizontaly
				}
				.buttonStyle(.borderedProminent)
				.disabled(viewModel.isSignInButtonDisabled) // how to disable while some condition is applied
				
				Button {
					presentationMode.wrappedValue.dismiss()
				} label: {
					Text("Cancel")
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderless)
			}
			.padding()
		}
		.toast(isPresenting: $viewModel.showToast) {
			AlertToast(type: viewModel.success ? .complete(.accentColor) : .error(.accentColor),
					   title: viewModel.success ? "Login successful!" : "Invalid credentials.",
					   subTitle: viewModel.success ? nil : "Please try again.")
		} completion: {
			if viewModel.success {
				viewModel.showToast = false
				presentationMode.wrappedValue.dismiss()
			}
		}
	}
}
	
struct SimpleHTTPLogoutView: View {
	@Environment(\.presentationMode) var presentationMode

	@ObservedObject var viewModel: SimpleHTTPLoginViewModel

	public var body: some View {
		VStack() {
			Text("Logout of \(viewModel.siteName)?")
				.font(.title2)
				.padding(10)
				.bold()
			
			Spacer()
			
			Button {
				viewModel.logout()
			} label: {
				Text("Log Out")
					.font(.title2)
					.bold()
					.foregroundColor(.white)
					.frame(maxWidth: .infinity) // how to make a button fill all the space available horizontaly
			}
			.frame(height: 50)
			.background(
				LinearGradient(colors: [.accentColor], startPoint: .topLeading, endPoint: .bottomTrailing)
			)
			.cornerRadius(20)
			.padding()
		}
		.toast(isPresenting: $viewModel.showToast) {
			AlertToast(type: .complete(.accentColor),
					   title: "Logout successful.")
		} completion: {
			if viewModel.success {
				viewModel.showToast = false
				presentationMode.wrappedValue.dismiss()
			}
		}
	}
}

	
public struct SimpleHTTPLoginView: View {

	@ObservedObject var viewModel: SimpleHTTPLoginViewModel
	
	@State var isAuthenticated = false
	
	public init(viewModel: SimpleHTTPLoginViewModel) {
		self.viewModel = viewModel
	}
	
	public var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			
			HStack {
				if let image = viewModel.siteImageName {
					Image(image)
				}
				
				Text(viewModel.siteName)
					.font(.system(size: 30, weight: .heavy))
					.foregroundColor(.accentColor)
			}
			.frame(maxWidth: .infinity)
			
			Spacer()
			
			if isAuthenticated {
				SimpleHTTPLogoutView(viewModel: viewModel)
			}
			else {
				SimpleHTTPLoginDetailView(viewModel: viewModel)
			}
		}
		.onAppear {
			isAuthenticated = viewModel.isAuthenticated
		}
	}
}

struct SimpleHTTPLoginView_Previews: PreviewProvider {
	
	static var viewModel = SimpleHTTPLoginViewModel(siteName: "MyBikeTrafffic",
													service: SimpleHTTPService.myBikeTrafficService,
													preview: true)
	
	static var previews: some View {
		SimpleHTTPLoginView(viewModel: viewModel)
	}
}


struct SimpleHTTPLoginViewPush_Previews: PreviewProvider {
	
	static var viewModel =  SimpleHTTPLoginViewModel(siteName: "MyBikeTraffic.com",
													 service: SimpleHTTPService.myBikeTrafficService,
													 preview: true )
	
	static var previews: some View {
		
		NavigationStack {
			List {
				NavigationLink(destination: SimpleHTTPLoginView(viewModel: viewModel)) {
					SimpletHHTPAuthRowView(viewModel: viewModel)
				}
			}
		}
		
	}
}
