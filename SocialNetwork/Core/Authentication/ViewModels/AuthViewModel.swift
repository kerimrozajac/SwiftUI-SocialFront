//
//  AuthViewModel.swift
//  SocialNetwork
//
//  Created by Sergey Leschev on 23/12/22.
//

import SwiftUI
import Firebase

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User? // Current logged-in user
    @Published var didAuthenticateUser = false    // Flag for successful registration
    @Published var currentUser: User?             // Current user data
    private var tempUserSession: FirebaseAuth.User? // Temporary session for newly registered user
    
    private let service = UserService() // User service for fetching user data
    
    // MARK: - Initializer
    init() {
        self.userSession = Auth.auth().currentUser
        self.fetchUser()
    }
    
    // MARK: - Login
    func login(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("DEBUG: Login failed with error: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            DispatchQueue.main.async {
                self?.userSession = user
                self?.fetchUser()
                print("DEBUG: Logged in as \(String(describing: self?.userSession?.email))")
            }
        }
    }
    
    // MARK: - Register
    func register(withEmail email: String, password: String, fullname: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("DEBUG: Registration failed with error: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            DispatchQueue.main.async {
                self?.tempUserSession = user
                
                let userData: [String: Any] = [
                    "email": email,
                    "username": username.lowercased(),
                    "fullname": fullname,
                    "uid": user.uid
                ]
                
                Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        print("DEBUG: Failed to upload user data with error: \(error.localizedDescription)")
                        return
                    }
                    print("DEBUG: User data uploaded successfully.")
                    self?.didAuthenticateUser = true
                }
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.didAuthenticateUser = false
                self.userSession = nil
                self.currentUser = nil
            }
            print("DEBUG: User logged out.")
        } catch {
            print("DEBUG: Failed to log out with error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Upload Profile Image
    func uploadProfileImage(_ image: UIImage) {
        guard let uid = tempUserSession?.uid else {
            print("DEBUG: User ID not found for profile image upload.")
            return
        }
        
        ImageUploader.uploadImage(image: image) { [weak self] profileImageUrl in
            Firestore.firestore().collection("users").document(uid).updateData(["profileImageUrl": profileImageUrl]) { error in
                if let error = error {
                    print("DEBUG: Failed to update profile image URL with error: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self?.userSession = self?.tempUserSession
                    self?.fetchUser()
                }
            }
        }
    }
    
    // MARK: - Fetch User
    func fetchUser() {
        guard let uid = userSession?.uid else {
            print("DEBUG: User ID not found for fetching user.")
            return
        }
        
        service.fetchUser(withUid: uid) { [weak self] user in
            DispatchQueue.main.async {
                self?.currentUser = user
                print("DEBUG: Fetched user: \(user.username)")
            }
        }
    }
}
