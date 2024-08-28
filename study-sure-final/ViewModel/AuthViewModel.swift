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
    @Published var userReviews: [Review] = []
    
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
    
    // Function to display users reviews on their profile view
    func fetchUserReviews() {
        guard let userId = userSession?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("reviews")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                var reviewsWithPendingCafeNames: [Review] = documents.compactMap { doc -> Review? in
                    var review = try? doc.data(as: Review.self)
                    review?.cafeName = "loading cafe name..."
                    self?.fetchCafeName(for: review)
                    return review
                }
                self?.userReviews = reviewsWithPendingCafeNames
            }
    }
    
    func fetchCafeName(for review: Review?) {
        guard let cafeId = review?.cafeId else { return }
        
        let db = Firestore.firestore()
        db.collection("cafes").document(cafeId).getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching cafe name: \(error)")
                return
            }
            if let document = documentSnapshot, document.exists,
               let cafeName = document.data()?["name"] as? String {
                DispatchQueue.main.async {
                    if let index = self.userReviews.firstIndex(where: { $0.id == review?.id }) {
                        self.userReviews[index].cafeName = cafeName
                    }
                }
            }
        }
    }
}
