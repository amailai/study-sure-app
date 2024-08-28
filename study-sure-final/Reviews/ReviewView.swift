//
//  ReviewView.swift
//  study-sure-final
//
//  Created by Clara O on 8/5/24.
//

import SwiftUI

struct ReviewView: View {
    var review: Review // accepts a single review obj
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
            VStack(alignment: .leading) {
                Text(userViewModel.userName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .onAppear {
                        userViewModel.fetchUserName(userId: review.userId)
                    }
                
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(review.rating) ? "star.fill" : "star")
                            .foregroundColor(index <= Int(review.rating) ? .yellow : .gray)
                    }
                }
                .padding(4)
                
                Text(review.comment)
                    .padding(.top, 2)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
}


