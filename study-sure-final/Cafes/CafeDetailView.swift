//
//  CafeDetailView.swift
//  study-sure-final
//
//  Created by Clara O on 8/1/24.
//

import SwiftUI
import MapKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct CafeDetailView: View {
    var cafe: Cafe
    let images = ["farine", "farine2", "farine3"]
    @State private var reviewsViewModel = ReviewsViewModel()
    @State private var showReview = false
    @State private var review = ""

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(cafe.mapItem.name ?? "Unknown Cafe")
                        .font(.largeTitle)
                        .padding(.top)
                    
                    if let address = cafe.mapItem.placemark.title {
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    if let distance = cafe.distance {
                        HStack {
                            Text("Distance: ")
                            Text(String(format: "%.2f miles away", distance / 1609.34)) // Convert meters to miles
                        }
                    }
                    
                    Text("Seats Available: " + String(cafe.seatsAvaliable))
                    
                    // Photo carousel
                    TabView {
                        ForEach(images, id: \.self) { imgName in
                            Image(imgName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 300)
                    
                    // Keywords of the cafe
                    //                    HStack {
                    //                        KeywordView(text: "comfy seating")
                    //                        KeywordView(text: "vegan/gf options")
                    //                    }
                    //
                    //                    HStack {
                    //                        KeywordView(text: "good coffee")
                    //                        KeywordView(text: "often busy")
                    //                    }
                    //
                    //                    Spacer()
                    
                   // section for reviews
                    if !reviewsViewModel.reviews.isEmpty {
                                        ForEach(reviewsViewModel.reviews) { review in
                                            ReviewView(review: review)
                                        }
                                    } else {
                                        Text("No reviews yet. Be the first to write one!")
                                    }
                    
                }
                .padding()
            }
            .navigationTitle("Cafe Details")
            .blur(radius: showReview ? 3 : 0)

            // Fixed position button in bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showReview = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.all)

            // Review Pop-Up
            if showReview {
                ReviewPopup(showReview: $showReview, review: $review, cafeId: cafe.identifier)
            }

            
        }
        .onAppear {
                   reviewsViewModel.fetchReviews(forCafe: cafe.identifier)  // Fetch reviews when the view appears
               }
    }
}

struct KeywordView: View {
    var text: String

    var body: some View {
        Text(text)
            .padding()
            .foregroundColor(.gray)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
    }
}

struct ReviewPopup: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var showReview: Bool
    @Binding var review: String
    var cafeId: String

    var body: some View {
        VStack {
            Text("Add a Review")
                .font(.headline)
                .padding()

            TextField("Write your review...", text: $review)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Submit") {
                // Handle the review submission here
                submitReview()
                withAnimation {
                    showReview = false
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button("Cancel") {
                withAnimation {
                    showReview = false
                }
            }
            .padding()
        }
        .frame(width: UIScreen.main.bounds.width, height: 250)
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
        let newReview = Review(userId: userId, cafeId: cafeId, rating: 5.0, comment: review)
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



