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
import FirebaseStorage

struct ReviewPopup: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var showReview: Bool
    @Binding var review: String
    @Binding var rating: Double
    var cafeId: String
    @State private var selectedKeywords: [String] = []
    
    
    let allKeywords = ["Cozy", "Spacious", "Quiet", "Busy", "Friendly Staff", "Great Coffee", "Affordable"]

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
            
            KeywordView(keywords: allKeywords, selectedKeywords: $selectedKeywords)
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
            print("Error: user is not logged in")
            return
        }
        
        let newReview = Review(userId: userId, cafeId: cafeId, rating: rating, comment: review, keywords: selectedKeywords)
        
        let db = Firestore.firestore()
        do {
            try db.collection("reviews").addDocument(from: newReview)
            print("Review added successfully.")
            withAnimation {
                showReview = false
                review = "" // Clear the review input field
                rating = 0 // Reset rating
                selectedKeywords = [] // Clear selected keywords
            }
        } catch let error {
            print("Error adding review: \(error.localizedDescription)")
        }
    }
    
}

