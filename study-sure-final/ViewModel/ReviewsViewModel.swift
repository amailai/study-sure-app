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
    
    func fetchReviews(forCafe cafeId: String) {
        db.collection("reviews")
            .whereField("cafeId", isEqualTo: cafeId)
            .addSnapshotListener{ (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No reviews found for cafe: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                self.reviews = documents.compactMap { try? $0.data(as: Review.self)}
            }
    }
}
