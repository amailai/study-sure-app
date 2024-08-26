//
//  ReviewsViewModel.swift
//  study-sure-final
//
//  Created by Clara O on 8/5/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine

class ReviewsViewModel: ObservableObject {
    @Published var reviews = [Review]()
    private var db = Firestore.firestore()
    // var for realtime updates when user uploads review
    private var listenerRegistration: ListenerRegistration?
    
    
    func fetchReviews(forCafe cafeID: String) {
        listenerRegistration?.remove() // Remove any existing listener to avoid dupes
        
        listenerRegistration = db.collection("reviews")
            .whereField("cafeId", isEqualTo: cafeID)
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    print("Error fetching reviews: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.reviews = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Review.self)
                }
            }
    }
    
    deinit {
        listenerRegistration?.remove() // Clean up listenerwhen the obj is deallocated
    }

}
