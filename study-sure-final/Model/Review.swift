//
//  Review.swift
//  study-sure-final
//
//  Created by Clara O on 8/5/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct Review: Codable, Identifiable {
    var id: String = UUID().uuidString
    var userId: String
    var cafeId: String
    var cafeName: String?
    var rating: Double
    var comment: String
    var userName: String? // store user's name
    var keywords: [String] // array to store selected keywords
    var seatsAvaliable: Int? // store seats avaliable in cafe 
    var imageUrls: [String] = [] // store image urls
}


