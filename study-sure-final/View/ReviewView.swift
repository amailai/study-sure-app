//
//  ReviewView.swift
//  study-sure-final
//
//  Created by Clara O on 8/5/24.
//

import SwiftUI

struct ReviewView: View {
    var review: Review // accepts a single review obj
    
    var body: some View {
        VStack(alignment: .leading) {
            // display the rating as stars
            HStack {
                ForEach(0..<Int(review.rating), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            Text(review.comment)
                .font(.subheadline)
                .padding()
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}


