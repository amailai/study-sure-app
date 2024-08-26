//
//  RatingView.swift
//  study-sure-final
//
//  Created by Clara O on 8/16/24.
//

import SwiftUI

struct RatingView: View {
    @Binding var rating: Double // binding so it can be used to submit the form
    
    var label = ""
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.yellow
    
    var body: some View {
        HStack {
            if !label.isEmpty {
                Text(label)
            }
            ForEach(1...maxRating, id: \.self) { number in
                self.image(for: number)
                    .foregroundColor(number > Int(self.rating) ? self.offColor: self.onColor)
                    .onTapGesture {
                        self.rating = Double(number)
                    }
            }
        }
    }
    
    // Function to "turn on" and "off" the color on the stars
    // for when they're selected 
    func image(for number: Int) -> Image {
        if number > Int(rating) {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
    
}


