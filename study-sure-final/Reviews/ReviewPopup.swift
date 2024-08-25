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
    @State private var availableSeats: String = "" // string to allow easy input handling
    @State private var selectedKeywords: [String] = []
    
    var cafeId: String
    var totalSeats: Int // pass total number of seats
    
    
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
            
            TextField("Avaliable Seats (out of \(totalSeats))", text: $availableSeats)
                .keyboardType(.numberPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            

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
                    selectedKeywords = []
                }
            }
            .padding()

        }
        .frame(width: UIScreen.main.bounds.width, height: 400)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .transition(.move(edge: .bottom))
    }
    
    func submitReview() {
        // only let logged in users submit reviews
        guard let userId = viewModel.userSession?.uid else {
            print("Error: user is not logged in")
            return
        }
        
        // guard on proper number of seats
        guard let seats = Int(availableSeats), seats <= totalSeats else {
            print("Invalid number of seats")
            return
        }
        
        let newReview = Review(userId: userId, cafeId: cafeId, rating: rating, comment: review, keywords: selectedKeywords)
        
        let db = Firestore.firestore()
        do {
            try db.collection("reviews").addDocument(from: newReview)
            print("Review added successfully.")
            updateCafeAvailableSeats(cafeId: cafeId, availableSeats: seats)  // Update cafe info
            withAnimation {
                showReview = false
                review = "" // Clear the review input field
                rating = 0 // Reset rating
                selectedKeywords = [] // Clear selected keywords
                availableSeats = "" // Clear seats inut
            }
        } catch let error {
            print("Error adding review: \(error.localizedDescription)")
        }
    }
    
}

private func updateCafeAvailableSeats(cafeId: String, availableSeats: Int) {
    let db = Firestore.firestore()
    db.collection("cafes").document(cafeId).updateData([
        "seatsAvailable": availableSeats 
    ]) { error in
        if let error = error {
            print("Error updating cafe seats: \(error.localizedDescription)")
        } else {
            print("Cafe seats updated successfully")
        }
    }
}


