//
//  CafeSearch.swift
//  study-sure-final
//
//  Created by Clara O on 7/31/24.
//

import Foundation
import MapKit
import FirebaseFirestore
import Combine

// each cafe is its own obj
// the cafe class
class Cafe: ObservableObject, Identifiable {
    let mapItem: MKMapItem
    var distance: CLLocationDistance?
    // currently set to 60 for each cafe, will have to manually set
    // once back in davis or something
    @Published var seatsAvailable: Int
    var identifier: String // use MKMapItem's placeID (unique identifier)
    
    init(mapItem: MKMapItem, distance: CLLocationDistance?, seatsAvailable: Int = 60) {
        self.mapItem = mapItem
        self.distance = distance
        self.seatsAvailable = seatsAvailable
        // create a unique identifier from the latitude and longtitude
        // of each cafe
        if let coordinate = mapItem.placemark.location?.coordinate {
            self.identifier = "\(coordinate.latitude), \(coordinate.longitude)"
        } else {
            self.identifier = UUID().uuidString // fallback to UUID if no coordinates are avaliable
        }
        fetchLatestSeatsAvaliable() // fetch latest data when cafe obj is created
    }
    
    func fetchLatestSeatsAvaliable() {
        let db = Firestore.firestore()
        db.collection("cafes").document(self.identifier).getDocument { documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                if let seatsAvailable = document.data()?["seatsAvaliable"] as? Int {
                    DispatchQueue.main.async {
                    self.seatsAvailable = seatsAvailable
                    }
                }
                    
            } else {
                print("Document does not exists or error: \(error?.localizedDescription ?? "Unknown error")")
                self.saveToFirestore()
            }
        }
    }
    
    func saveToFirestore() {
        let db = Firestore.firestore()
        db.collection("cafes").document(self.identifier).setData([
            "name" : self.mapItem.name ?? "Unknown Cafe",
            "address" : self.mapItem.placemark.title ?? "No Address",
            "coordinates" : "\(self.mapItem.placemark.coordinate.latitude), \(self.mapItem.placemark.coordinate.longitude)",
            "seatsAvailable": self.seatsAvailable
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
        
        let dispatchGroup = DispatchGroup()
        var cafes: [Cafe] = []
        
        for mapItem in response.mapItems {
            let distance = mapItem.placemark.location?.distance(from: location) ?? 0
            let cafe = Cafe(mapItem: mapItem, distance: distance)
            
            dispatchGroup.enter()
            
            // attempt to fetch existing seatsAvaliable from Firestore
            let db = Firestore.firestore()
            db.collection("cafes").document(cafe.identifier).getDocument { documentSnapshot, error in
                if let document = documentSnapshot, document.exists {
                    if let seatsAvailable = document.data()?["seatsAvailable"] as? Int {
                        DispatchQueue.main.async {
                            cafe.seatsAvailable = seatsAvailable
                        }
                    }
                } else {
                    print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
                }
                cafes.append(cafe)
                dispatchGroup.leave()
            }
            
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(cafes)
        }
    }
    
}
