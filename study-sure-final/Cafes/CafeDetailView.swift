//
//  CafeDetailView.swift
//  study-sure-final
//
//  Created by Clara O on 8/1/24.
//

import SwiftUI
import MapKit

struct CafeDetailView: View {
    var cafe: Cafe
    let images = ["farine", "farine2", "farine3"]
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
                    HStack {
                        KeywordView(text: "comfy seating")
                        KeywordView(text: "vegan/gf options")
                    }
                    
                    HStack {
                        KeywordView(text: "good coffee")
                        KeywordView(text: "often busy")
                    }
                    
                    Spacer()
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
                ReviewPopup(showReview: $showReview, review: $review)
            }
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
    @Binding var showReview: Bool
    @Binding var review: String

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
                print("Review submitted: \(review)")
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
}



