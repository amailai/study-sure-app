//
//  RegistrationView.swift
//  study-sure-final
//
//  Created by Clara O on 7/19/24.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        ZStack {
            Color(hex: "#fbd3ce")
                .ignoresSafeArea()
            VStack {
                // image
                Image("mug")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                    .padding(.vertical, 32)
                
                // form fields
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    InputView(text: $fullName, title: "Full Name", placeholder: "Enter your name")
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter your password")
                    
                    ZStack(alignment: .trailing) {
                        InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm your password")
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemBlue))
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemRed))
                            }
                        }
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // sign-in button
                Button {
                    Task {
                        try await viewModel.createUser(withEmail: email, password: password, fullName: fullName)
                    }
                } label: {
                    HStack {
                        Text("SIGN UP")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(hex: "#614d3b"))
                .disabled(!formIsValid)
    //             if form is valid opacity is 1.0 if not 0.5
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 3) {
                        Text("Already have an account?")
                        Text("Sign in")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#614d3b"))
                }
            }
        }
    }
}

extension RegistrationView : AuthenticationFormProtocol {
    // checking to see if the email entered has an @
    // and the password is greater than 5 characters
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword ==  password
        && !fullName.isEmpty
    }
}

#Preview {
    RegistrationView()
}
