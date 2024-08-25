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
    
    //old fetch reviews function before adding updating
//    func fetchReviews(forCafe cafeId: String) {
//            db.collection("reviews")
//                .whereField("cafeId", isEqualTo: cafeId)
//                .getDocuments { (querySnapshot, error) in
//                    if let error = error {
//                        print("Error fetching reviews: \(error)")
//                        return
//                    }
//
//                    let group = DispatchGroup()
//
//                    var reviewsWithUser: [Review] = []
//                    
//                    for document in querySnapshot!.documents {
//                        var review = try! document.data(as: Review.self)
//                        
//                        group.enter()
//                        self.db.collection("users").document(review.userId).getDocument { (userSnapshot, error) in
//                            if let userData = try? userSnapshot?.data(as: User.self) {
//                                review.userName = userData.fullName // Assuming the user model has a fullName field
//                            }
//                            reviewsWithUser.append(review)
//                            group.leave()
//                        }
//                    }
//
//                    group.notify(queue: .main) {
//                        self.reviews = reviewsWithUser
//                    }
//                }
//        }

}
