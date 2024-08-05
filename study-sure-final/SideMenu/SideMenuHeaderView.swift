//
//  SideMenuHeaderView.swift
//  study-sure-final
//
//  Created by Clara O on 7/28/24.
//

import SwiftUI

struct SideMenuHeaderView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if let user = viewModel.currentUser {
            HStack {
                Image(systemName: "person.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(user.fullName)
                        .font(.subheadline)
                    
                    Text(user.email)
                        .font(.footnote)
                        .tint(.gray)
                    }
                }
            }
        }
    }


#Preview {
    SideMenuHeaderView()
}
