//
//  study_sure_finalApp.swift
//  study-sure-final
//
//  Created by Clara O on 7/19/24.
//

import SwiftUI
import Firebase

@main
struct study_sure_finalApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
