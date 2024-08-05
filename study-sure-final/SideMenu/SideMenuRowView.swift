//
//  SideMenuRowView.swift
//  study-sure-final
//
//  Created by Clara O on 7/28/24.
//

import SwiftUI

struct SideMenuRowView: View {
    let option: SideMenuOptionModel
    @Binding var selectedOption: SideMenuOptionModel?
    
    private var isSelected: Bool {
        return selectedOption == option
    }
    
    var body: some View {
        HStack {
            Image(systemName: option.systemImageName)
                .imageScale(.small)
            
            Text(option.title)
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.leading)
        // if tab is selected display blue, if not do primary color
        .foregroundStyle(isSelected ? .blue : .primary)
        .frame(width: 216, height: 44)
        // if tab is selected show a blue rectangle around it
        .background(isSelected ? .blue.opacity(0.25) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    
        
    }
}

#Preview {
    SideMenuRowView(option: .home, selectedOption: .constant(.home))
}


