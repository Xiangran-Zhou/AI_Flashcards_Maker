//
//  LoginView.swift
//  AI_Flashcards_Maker
//
//  Created by kevin zhou on 11/24/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var showRegistrationView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("AI Flashcards Maker")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                Image("appstore")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Rectangle())
                    .overlay(
                        Rectangle().stroke(Color.black, lineWidth: 2)
                    )
                    .padding(.bottom, 20)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .textInputAutocapitalization(.none)
                    .disableAutocorrection(true)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.none)
                    .disableAutocorrection(true)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

                Button(action: {
                    LoginController().loginUser(username: username, email: email, password: password) { success, error in
                        if success {
                            isLoggedIn = true
                        } else {
                            errorMessage = error ?? "Unknown error"
                        }
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Register here")
                        .foregroundColor(.black)
                        .underline()
                }
                .padding(.top, 10)
            }
            .padding()
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isLoggedIn) {
                MainContentView(username: username)
            }
        }
    }
}


