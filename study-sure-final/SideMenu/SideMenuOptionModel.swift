//
//  SideMenuOptionModel.swift
//  study-sure-final
//
//  Created by Clara O on 7/28/24.
//

import Foundation

enum SideMenuOptionModel: Int, CaseIterable {
    case home
    case profile
    case cafes
    // have stats and favorites commented out right now
    // can add the functionality for these later
//    case stats
//    case favorites
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .profile:
            return "Profile"
        case .cafes:
            return "Cafes"
//        case .stats:
//            return "Stats"
//        case .favorites:
//            return "Favorites"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .home:
            return "house"
        case .profile:
            return "person"
        case .cafes:
            return "cup.and.saucer"
//        case .stats:
//            return "square.and.pencil"
//        case .favorites:
//            return "star"
        }
    }
    
}

extension SideMenuOptionModel: Identifiable {
    var id: Int { return self.rawValue }
}


