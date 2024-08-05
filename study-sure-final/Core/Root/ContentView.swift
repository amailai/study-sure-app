//
//  ContentView.swift
//  study-sure-final
//
//  Created by Clara O on 7/19/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        // if user is logged in already, send to profile view of app
        // if user is not logged in, send to login view
        Group {
            if viewModel.userSession != nil {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
