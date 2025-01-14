//
//  LoginController.swift
//  AI_Flashcards_Maker
//
//  Created by kevin zhou on 11/24/24.
//
import FirebaseAuth
import FirebaseFirestore

class LoginController {
    func loginUser(username: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let nsError = error as NSError
                completion(false, nsError.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
}
