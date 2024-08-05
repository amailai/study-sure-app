//
//  ReviewPopup.swift
//  study-sure-final
//
//  Created by Clara O on 8/16/24.
//

import SwiftUI
import MapKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ReviewPopup: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var showReview: Bool
    @Binding var review: String
    @Binding var rating: Double
    var cafeId: String

    var body: some View {
        VStack {
            Text("Add a Review")
                .font(.headline)
                .padding()
            
            RatingView(rating: $rating, label: "Your rating:")
                .padding()

            TextField("Write your review...", text: $review)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Submit") {
                // Handle the review submission here
                submitReview()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button("Cancel") {
                withAnimation {
                    showReview = false
                    review = ""
                    rating = 0
                }
            }
            .padding()
        }
        .frame(width: UIScreen.main.bounds.width, height: 350)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .transition(.move(edge: .bottom))
    }
    
    func submitReview() {
        guard let userId = viewModel.userSession?.uid else {
            print("error: user is not logged in")
            return
        }
        let newReview = Review(userId: userId, cafeId: cafeId, rating: rating, comment: review)
        let db = Firestore.firestore()
        do {
            try db.collection("reviews").addDocument(from: newReview)
            print("Review added successfully")
        } catch let error {
            print("Error adding review: \(error.localizedDescription)")
        }
        withAnimation {
            showReview = false
            review = "" // clear the review input field
        }
    }
}

