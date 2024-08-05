//
//  MapView.swift
//  study-sure-final
//
//  Created by Clara O on 7/31/24.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let location: CLLocation
    let cafes: [Cafe]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let annotations = cafes.map { cafe -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = cafe.mapItem.name
            annotation.coordinate = cafe.mapItem.placemark.coordinate
            return annotation
        }
        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}


