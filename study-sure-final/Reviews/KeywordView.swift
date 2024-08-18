//
//  KeywordView.swift
//  study-sure-final
//
//  Created by Clara O on 8/18/24.
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
                        if selectedKeywords.contains(keyword) {
                            selectedKeywords.removeAll(where: { $0 == keyword })
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
            .padding(.horizontal, 10)
        }
    }
}

