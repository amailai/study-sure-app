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
    @StateObject private var reviewsViewModel = ReviewsViewModel()
    @State private var showReview = false
    @State private var review = ""
    @State private var rating: Double = 0

    var body: some View {
        ZStack {
//            Color(hex: "#fbd3ce")
//                .ignoresSafeArea()
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
                    
                   // section for reviews
                    Text("Reviews")
                        .font(.headline)
                        .padding(.top)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if !reviewsViewModel.reviews.isEmpty {
                                                ForEach(reviewsViewModel.reviews) { review in
                                                    ReviewView(review: review)
                                                        .frame(width: 250) // set a fixed width for each review
                                                        .padding(.trailing, 5) // space between reviews
                                                }
                            } else {
                                Text("No reviews yet. Be the first to write one!")
                                    .padding()
                            }
                        }
                    }
                    .frame(height: 150) // set the height for the reviews section
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
                ReviewPopup(showReview: $showReview, review: $review, rating: $rating, cafeId: cafe.identifier)
            }

            
        }
        .onAppear {
                   reviewsViewModel.fetchReviews(forCafe: cafe.identifier)  // Fetch reviews when the view appears
               }
    }
}






