//
//  SettingsView.swift
//  study-sure-final
//
//  Created by Clara O on 7/19/24.
//

import SwiftUI

struct SettingsView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    SettingsView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
        
}
