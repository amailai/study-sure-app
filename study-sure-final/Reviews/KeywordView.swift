//
//  KeywordView.swift
//  study-sure-final
//
//  Created by Clara O on 8/17/24.
//

import SwiftUI

struct KeywordView: View {
    let keywords: [String]
    @Binding var selectedKeywords: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(keywords, id: \.self) { keyword in
                    Button(action: {
                        // if keyword already selected then remove it from selection
                        if selectedKeywords.contains(keyword) {
                            selectedKeywords.removeAll { $0 == keyword }
                            // else add it in the list
                        } else {
                            selectedKeywords.append(keyword)
                        }
                    }) {
                        Text(keyword)
                            .padding()
                            .background(selectedKeywords.contains(keyword) ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 4)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
    }
}


