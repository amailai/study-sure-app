//
//  ReviewDetailView.swift
//  study-sure-final
//
//  Created by Clara O on 8/26/24.
//

import SwiftUI

struct ReviewDetailView: View {
    var review: Review?
    @Binding var isPresented: Bool
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    self.isPresented = false
                    print("Close button tapped")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 10)
                .padding(.top, 10)

                Spacer()
            }

            Spacer()
            
            if let review = review {
                VStack(alignment: .center, spacing: 20) {
                    Text("Review by \(userViewModel.userName)")
                        .font(.title)
                        .padding()
                        .onAppear {
                            userViewModel.fetchUserName(userId: review.userId)
                        }
                    HStack {
                        ForEach(0..<Int(review.rating), id: \.self) { _ in
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                        }
                        ForEach(Int(review.rating)..<5, id: \.self) { _ in
                            Image(systemName: "star").foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    ScrollView {
                        Text(review.comment).padding()
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                Text("No review selected.")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.95))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

