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
    @ObservedObject var cafe: Cafe
//    let images = ["farine", "farine2", "farine3"]
    @StateObject private var reviewsViewModel = ReviewsViewModel()
    @State private var showReview = false
    @State private var review = ""
    @State private var rating: Double = 0
    @State private var selectedKeywords: [String] = []
    

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
                    
                    Text("Seats Available: \(cafe.seatsAvailable)")
                    
                    let existingImages = ["farine", "farine2", "farine3"]
                    let reviewImages = reviewsViewModel.reviews.flatMap { $0.imageUrls }
                    let allImages = existingImages.map { ImageItem(imageUrl: nil, imageName: $0) } +
                                    reviewImages.map { ImageItem(imageUrl: $0, imageName: nil) }
                    // Display photos associated with the cafe's reviews
                    if !allImages.isEmpty {
                        TabView {
                            ForEach(allImages, id: \.id) { imageItem in
                                if let imageName = imageItem.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 350, height: 300)
                                        .cornerRadius(10)  // Apply corner radius
                                        .padding()
                                } else if let imageUrl = imageItem.imageUrl {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 350, height: 300)
                                    .cornerRadius(10)  // Apply corner radius
                                    .padding()
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 300)
                    }
                    
                    
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
                ReviewPopup(
                    showReview: $showReview,
                    review: $review,
                    rating: $rating,
                    cafeId: cafe.identifier,
                    maxSeats: cafe.maxSeats
                )
            }

            
        }
        .onAppear {
            reviewsViewModel.fetchReviews(forCafe: cafe.identifier)  // Fetch reviews when the view appears
            
            let db = Firestore.firestore()
            db.collection("cafes").document(cafe.identifier).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                if let seatsAvailable = document.data()?["seatsAvailable"] as? Int {
                    DispatchQueue.main.async {
                        cafe.seatsAvailable = seatsAvailable
                    }
                    
                }
                    
                    
            }
        }
    }
}

struct ImageItem: Identifiable {
    var id = UUID()
    var imageUrl: String?
    var imageName: String?
}
                                                                                                                                    





