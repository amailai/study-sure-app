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
    
    var body: some View {
        VStack(alignment: .center, spacing: 20){
            Text("Detailed Review")
                .font(.title)
                .padding()
            if let review = review {
                ScrollView {
                    Text(review.comment)
                        .padding()
                }
            } else {
                Text("No review selected.")
            }
            
            Button("Close") {
                isPresented = false
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.95))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

