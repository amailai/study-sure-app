//
//  UserViewModel.swift
//  study-sure-final
//
//  Created by Clara O on 8/25/24.
//

import Foundation
import Firebase
import FirebaseFirestore

// class to get fullName from users collection when displaying the name
// on the review, since the review only stores the userId
class UserViewModel: ObservableObject {
    @Published var userName: String = "Unknown User"
    
    func fetchUserName(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                if let fullName = document.data()?["fullName"] as? String {
                    DispatchQueue.main.async {
                        self.userName = fullName
                    }
                }
            } else {
                print("User not found or error: \(error?.localizedDescription ?? "Unknown error")")
            }
            
        }
    }
}
