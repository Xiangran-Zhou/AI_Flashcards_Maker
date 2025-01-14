//
//  RegisterView.swift
//  AI_Flashcards_Maker
//
//  Created by kevin zhou on 11/24/24.
//
import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            // Title of the register page
            Text("Register")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)

            // User Input Fields
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

            SecureField("Password (Min 6 chars)", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            // Display error message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            // Register Button
            Button(action: {
                RegisterController().registerUser(username: username, email: email, password: password, confirmPassword: confirmPassword) { success, error in
                    if success {
                        showAlert = true
                    } else {
                        errorMessage = error ?? "Unknown error"
                    }
                }
            }) {
                Text("Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline) // Set the display mode to inline
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                Text("Back")
                    .foregroundColor(.black)
            }
        })
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Registration Success"),
                message: Text("Your account has been created successfully."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
