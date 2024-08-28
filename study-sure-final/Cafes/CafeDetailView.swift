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
    @StateObject private var reviewsViewModel = ReviewsViewModel()
    @State private var showReview = false
    @State private var review = ""
    @State private var rating: Double = 0
    @State private var selectedKeywords: [String] = []
    @State private var selectedReview: Review?
    @State private var showingDetail = false
    

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
                    
                    Text("Seats Available: \(cafe.seatsAvailable)")
                    if let lastUpdated = cafe.lastUpdated {
                        Text("Last Updated: \(lastUpdated.timeAgoDisplay())")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("Last Updated: Not avaliable")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
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
                    
                    // section for keywords
                    let uniqueKeywords = Set(reviewsViewModel.reviews.flatMap { $0.keywords })
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(uniqueKeywords.sorted(), id: \.self) { keyword in
                                Text(keyword)
                                    .padding(8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(2)
                            }
                        }
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
                                        .onTapGesture {
                                            self.selectedReview = review
                                            self.showingDetail = true
                                        }
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

            // Present detailed review when a review is selected
            if showingDetail {
                ReviewDetailView(review: selectedReview, isPresented: $showingDetail)
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
                if let lastUpdatedTimestamp = document.data()?["lastUpdated"] as? Timestamp {
                            DispatchQueue.main.async {
                                cafe.lastUpdated = lastUpdatedTimestamp.dateValue()
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

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
                                                                                                                                    





