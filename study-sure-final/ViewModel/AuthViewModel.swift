//
//  AuthViewModel.swift
//  study-sure-final
//
//  Created by Clara O on 7/20/24.

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}

@MainActor
class AuthViewModel: ObservableObject {
    // tells whether or not you have a user logged in
    // firebase user obj
    @Published var userSession: FirebaseAuth.User?
    // our created user obj
    @Published var currentUser: User?
    
    init() {
        // cache information if someone is logged in on the device
        self.userSession = Auth.auth().currentUser
        
        Task {
            // when opening app try and fetch user
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: failed to log in with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            // creating user and getting stuff back from firebase
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            //if we get successful result back...
            self.userSession = result.user
            // creating user obj
            let user = User(id: result.user.uid, fullName: fullName, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            // saving users info in backend
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            // once we create user we need to fetch the data we just uploaded so it can
            // be properly displayed
            await fetchUser()
        } catch {
            print("DEBUG: failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() // signs out user on backend
            self.userSession = nil // wipes out user sessions and takes back to login screen
            self.currentUser = nil // wipes out current user data model
        } catch {
            print("DEBUG: failed to sign out with error \(error.localizedDescription)")
        }
        
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        // getting actual user info when they log in
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        print("DEBUG: current user is \(self.currentUser)")
    }
}
