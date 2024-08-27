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
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    
    var cafeId: String
    var maxSeats: Int // pass total number of seats
    
    
    let allKeywords = ["Cozy", "Spacious", "Quiet", "Busy", "Friendly Staff", "Great Coffee", "Affordable", "Wifi", "Indoor Seating", "Outdoor Seating", "Great Food", "Vegetarian Options", "GF Options"]
    
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
            
            TextField("Avaliable Seats (out of \(maxSeats))", text: $availableSeats)
                .keyboardType(.numberPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Select Photos") {
                showImagePicker = true
            }
            .padding()
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                            .padding(4)
                    }
                }
            }
            
            Button("Submit") {
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
        .frame(width: UIScreen.main.bounds.width, height: 600)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .transition(.move(edge: .bottom))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
    }
    
    func submitReview() {
            guard let userId = viewModel.userSession?.uid else {
                print("Error: user is not logged in")
                return
            }
            
            guard let seats = Int(availableSeats), seats <= maxSeats else {
                print("Invalid number of seats. Must be between 0 and \(maxSeats).")
                return
            }
            
            if selectedImages.isEmpty {
                // No images selected, submit review without images
                let newReview = Review(
                    userId: userId,
                    cafeId: cafeId,
                    rating: rating,
                    comment: review,
                    keywords: selectedKeywords,
                    imageUrls: [] // No images
                )
                saveReviewToFirestore(newReview: newReview, availableSeats: seats)
            } else {
                // Images selected, upload them first
                uploadImages { urls in
                    let newReview = Review(
                        userId: userId,
                        cafeId: cafeId,
                        rating: rating,
                        comment: review,
                        keywords: selectedKeywords,
                        imageUrls: urls // Include uploaded image URLs
                    )
                    saveReviewToFirestore(newReview: newReview, availableSeats: seats)
                }
            }
        }
    
    private func saveReviewToFirestore(newReview: Review, availableSeats: Int) {
            let db = Firestore.firestore()
            do {
                try db.collection("reviews").addDocument(from: newReview)
                print("Review added successfully.")
                updateCafeAvailableSeats(cafeId: cafeId, availableSeats: availableSeats)  // Update cafe info
                withAnimation {
                    showReview = false
                    review = ""
                    rating = 0
                    selectedKeywords = []
                    selectedImages = []
                }
            } catch let error {
                print("Error adding review: \(error.localizedDescription)")
            }
        }
        
        func uploadImages(completion: @escaping ([String]) -> Void) {
            let storage = Storage.storage()
            var uploadedImageUrls: [String] = []
            
            for image in selectedImages {
                let imageData = image.jpegData(compressionQuality: 0.8)
                let fileName = UUID().uuidString
                let storageRef = storage.reference().child("cafe_images/\(cafeId)/\(fileName).jpg")
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                storageRef.putData(imageData!, metadata: metadata) { metadata, error in
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                        return
                    }
                    
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error fetching download URL: \(error.localizedDescription)")
                            return
                        }
                        
                        if let url = url {
                            uploadedImageUrls.append(url.absoluteString)
                            
                            // If all images are uploaded, return the URLs
                            if uploadedImageUrls.count == self.selectedImages.count {
                                completion(uploadedImageUrls)
                            }
                        }
                    }
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
    }

