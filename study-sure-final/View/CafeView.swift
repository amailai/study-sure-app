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

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
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
                    List(cafes, id: \.mapItem) { cafe in
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
//                .background(Color(hex: "#fbd3ce")
//                    .ignoresSafeArea())
            }
        }
    }
}


#Preview {
    CafeView()
}
