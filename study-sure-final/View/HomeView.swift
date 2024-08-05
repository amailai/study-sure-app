//
//  HomeView.swift
//  study-sure-final
//
//  Created by Clara O on 7/28/24.
//

import SwiftUI

struct HomeView: View {
    @State private var showMenu = false
    @State private var selectedTab = 0
    @EnvironmentObject var viewModel: AuthViewModel
    @ObservedObject var locationManager = LocationManager()
    @State private var closestCafe: Cafe?
    var body: some View {
        // if user logged in already bring to home page
        if let user = viewModel.currentUser {
            NavigationStack{
                ZStack {
                    TabView(selection: $selectedTab) {
                        Text("Welcome Back " + user.fullName)
                            .padding()
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(10)
                            .padding()
                        
                            .tag(0)
                        
                
                        ProfileView()
                            .tag(1)
                        
                        CafeView()
                            .tag(2)
                        
//                        StatsView()
//                            .tag(3)
//                        
//                        FavoritesView()
//                            .tag(4)
                    }
    
                    
                    SideMenuView(isShowing: $showMenu, selectedTab: $selectedTab)
                    
                }

                // this line below hides the navigation bar
                // when the tool bar is open
                .toolbar(showMenu ? .hidden: .visible, for: .navigationBar)
//                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            showMenu.toggle()
                        }, label: {
                            Image(systemName: "line.3.horizontal")
                        })
                        
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
