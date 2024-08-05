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
    
//    func fetchReviews(forCafe cafeId: String) {
//        print("Fetching reviews for cafe: \(cafeId)")
//        db.collection("reviews")
//            .whereField("cafeId", isEqualTo: cafeId)
//            .addSnapshotListener { (querySnapshot, error) in
//                if let error = error {
//                    print("Error fetching reviews: \(error.localizedDescription)")
//                    return
//                }
//
//                guard let documents = querySnapshot?.documents else {
//                    print("No documents in 'reviews' collection")
//                    return
//                }
//
//                self.reviews = documents.compactMap { document in
//                    try? document.data(as: Review.self)
//                }
//            }
//    }
    
    func fetchReviews(forCafe cafeId: String) {
            db.collection("reviews")
                .whereField("cafeId", isEqualTo: cafeId)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching reviews: \(error)")
                        return
                    }

                    let group = DispatchGroup()

                    var reviewsWithUser: [Review] = []
                    
                    for document in querySnapshot!.documents {
                        var review = try! document.data(as: Review.self)
                        
                        group.enter()
                        self.db.collection("users").document(review.userId).getDocument { (userSnapshot, error) in
                            if let userData = try? userSnapshot?.data(as: User.self) {
                                review.userName = userData.fullName // Assuming the user model has a fullName field
                            }
                            reviewsWithUser.append(review)
                            group.leave()
                        }
                    }

                    group.notify(queue: .main) {
                        self.reviews = reviewsWithUser
                    }
                }
        }

}
