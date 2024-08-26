//
//  CafeView.swift
//  study-sure-final
//
//  Created by Clara O on 7/28/24.
//

import SwiftUI
import MapKit

struct CafeView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var cafes: [Cafe] = []
    @State private var searchText = ""

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    TextField("Search for Cafes", text: $searchText)
                        .padding(.leading, 30)
                        .padding(7)
                        .background(
                            Color(.systemGray6)
                                .cornerRadius(8)
                                .overlay(
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 8)
                                    }
                                )
                        )
                        .padding(.horizontal)
                    
                    if let location = locationManager.location {
                        MapView(location: location, cafes: cafes)
                            .onAppear {
                                searchCafes(near: location) { newCafes in
                                    self.cafes = newCafes
                                }
                            }
                    } else {
                        Text("Fetching location...")
                    }
                    List(filteredCafes(), id: \.mapItem) { cafe in
                        NavigationLink(destination: CafeDetailView(cafe: cafe)) {
                            VStack(alignment: .leading) {
                                Text(cafe.mapItem.name ?? "Unknown")
                                Text(cafe.mapItem.placemark.title ?? "No address")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                if let distance = cafe.distance {
                                    Text(String(format: "%.2f miles away", distance / 1609.34)) // Convert meters to miles
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Nearby Study Spots")
            }
        }
    }
    
    // Function to filter cafes based on search text
    private func filteredCafes() -> [Cafe] {
        if searchText.isEmpty {
            return cafes
        } else {
            return cafes.filter { cafe in
                cafe.mapItem.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
}


#Preview {
    CafeView()
}
