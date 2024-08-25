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
                Text(review.comment)
                    .padding(.top, 2)
                
                // display keywords
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(review.keywords, id: \.self) { keyword in
                            Text(keyword)
                                .padding(5)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal, 10)
                    }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
}


