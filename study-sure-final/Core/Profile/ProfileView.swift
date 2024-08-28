//
//  ProfileView.swift
//  study-sure-final
//
//  Created by Clara O on 7/19/24.
//
// problem with profile view??, not displaying in simulation

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    
                }
                
                Section("My Reviews") {
                    ForEach(viewModel.userReviews, id: \.id) { review in
                        VStack(alignment: .leading) {
                            Text(review.cafeName ?? "Unknown Cafe")
                                .font(.headline)
                            
                            // Star rating display
                            HStack {
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= Int(review.rating) ? "star.fill" : "star")
                                        .foregroundColor(index <= Int(review.rating) ? .yellow : .gray)
                                }
                            }
                            .padding(4)
                            
                            Text(review.comment)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Account") {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                    Button {
                        print("Delete...")
                    } label: {
                        SettingsView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                    }
                }
            }
            .onAppear{
                viewModel.fetchUserReviews() // fetch user reviews when opening profile view
            }
        }
    }
}

#Preview {
    ProfileView()
       .environmentObject(AuthViewModel())
}
