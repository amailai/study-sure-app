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
    @State private var imageUploads = [UIImage]()
    @State private var isShowingImagePicker = false
    
    
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
            
            Button("Upload Image") {
                isShowingImagePicker = true
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(imageUploads, id: \.self) { img in
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
            
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(images: $imageUploads)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 400)
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
        
        uploadImages { urls in
            // Assuming Review model is updated to include an imageUrls field that accepts URLs.
            let newReview = Review(userId: userId, cafeId: cafeId, rating: rating, comment: review, keywords: selectedKeywords, imageUrls: urls)

            let db = Firestore.firestore()
            do {
                try db.collection("reviews").addDocument(from: newReview)
                print("Review added successfully.")
                withAnimation {
                    showReview = false
                    review = "" // Clear the review input field
                    rating = 0 // Reset rating
                    selectedKeywords = [] // Clear selected keywords
                    imageUploads = [] // Clear images if used
                }
            } catch let error {
                print("Error adding review: \(error.localizedDescription)")
            }
        }
    }
    
    private func uploadImages(completion: @escaping ([String]) -> Void) {
        var uploadedUrls = [String]()
        let storage = Storage.storage()
        
        for image in imageUploads {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            let storageRef = storage.reference().child("review_images/\(UUID().uuidString).jpg")
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                guard metadata != nil else {
                    print("Failed to upload image: \(error?.localizedDescription ?? "")")
                    return
                }
                
                storageRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        print("Download URL not found")
                        return
                    }
                    uploadedUrls.append(downloadURL.absoluteString)
                    if uploadedUrls.count == imageUploads.count {
                        completion(uploadedUrls)
                    }
                    
                }
            }
        }
    }
}

