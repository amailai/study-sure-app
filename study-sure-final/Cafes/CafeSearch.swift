//
//  CafeSearch.swift
//  study-sure-final
//
//  Created by Clara O on 7/31/24.
//

import Foundation
import MapKit
import FirebaseFirestore

// each cafe is its own obj
// the cafe class
struct Cafe {
    let mapItem: MKMapItem
    var distance: CLLocationDistance?
    // currently set to 60 for each cafe, will have to manually set
    // once back in davis or something
    var seatsAvaliable: Int
    var identifier: String // use MKMapItem's placeID (unique identifier)
    
    init(mapItem: MKMapItem, distance: CLLocationDistance?, seatsAvaliable: Int) {
        self.mapItem = mapItem
        self.distance = distance
        self.seatsAvaliable = seatsAvaliable
        // create a unique identifier from the latitude and longtitude
        // of each cafe
        if let coordinate = mapItem.placemark.location?.coordinate {
            self.identifier = "\(coordinate.latitude), \(coordinate.longitude)"
        } else {
            self.identifier = UUID().uuidString // fallback to UUID if no coordinates are avaliable
        }
    }
    
    func saveToFirestore() {
        let db = Firestore.firestore()
        db.collection("cafes").document(self.identifier).setData([
            "name" : self.mapItem.name ?? "Unknown Cafe",
            "address" : self.mapItem.placemark.title ?? "No Address",
            "coordinates" : "\(self.mapItem.placemark.coordinate.latitude), \(self.mapItem.placemark.coordinate.longitude)",
            "seatsAvaliable": self.seatsAvaliable
        ]) { error in
            if let error = error {
                print("Error saving cafe: \(error.localizedDescription)")
            } else {
                print("Cafe saved successfully")
            }
        }
    }
    
}

// search for nearby cafes based on user location
func searchCafes(near location: CLLocation, completion: @escaping ([Cafe]) -> Void) {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = "coffee"
    request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
    
    let search = MKLocalSearch(request: request)
    search.start { response, error in
        guard let response = response else {
            print("Error: \(error?.localizedDescription ?? "Unknown error").")
            return
        }
        let cafes = response.mapItems.map { mapItem -> Cafe in
            let distance = mapItem.placemark.location?.distance(from: location) ?? 0
            let cafe = Cafe(mapItem: mapItem, distance: distance, seatsAvaliable: 60)
//            return Cafe(mapItem: mapItem, distance: distance, seatsAvaliable: 60)
            cafe.saveToFirestore() // optionally save cafe details to fire store
            return cafe
        }
        completion(cafes)
    }
}
