//
//  MapController.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 06/08/26.
//
//  VIEWMODEL — Holds map state, location logic, and the MKMapViewDelegate.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI
import Combine

class MapViewModel: ObservableObject {

    @Published var centerOnUser = false

    let floodZones: [FloodZone] = FloodZone.sampleZones
    let locationManager = CLLocationManager()

    /// Adds a pin annotation for each flood zone.
    func addPins(to mapView: MKMapView) {
        for zone in floodZones {
            let pin = FloodZoneAnnotation()
            pin.coordinate = zone.center
            pin.title = zone.name
            pin.subtitle = "\(zone.status.statusEmoji) \(zone.status.rawValue)"
            pin.status = zone.status
            pin.zoneName = zone.name
            pin.zoneDescription = zone.description
            mapView.addAnnotation(pin)
        }
    }

    /// Centers the map on the user's current location.
    func centerOnUserLocation(mapView: MKMapView) {
        guard let location = mapView.userLocation.location else { return }
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
    }

    /// Requests location permission.
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - Map Delegate

/// Handles pin rendering and zoom-based card visibility.
class MapCoordinator: NSObject, MKMapViewDelegate {

    private let zoomThreshold: Double = 0.05

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        guard let flood = annotation as? FloodZoneAnnotation else { return nil }

        var view = mapView.dequeueReusableAnnotationView(
            withIdentifier: FloodZoneAnnotationView.reuseID
        ) as? FloodZoneAnnotationView

        if view == nil {
            view = FloodZoneAnnotationView(annotation: flood, reuseIdentifier: FloodZoneAnnotationView.reuseID)
        } else {
            view?.annotation = flood
        }

        view?.configure(with: flood)
        view?.isCardVisible = mapView.region.span.latitudeDelta < zoomThreshold

        return view
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let isZoomedIn = mapView.region.span.latitudeDelta < zoomThreshold

        for annotation in mapView.annotations {
            if let flood = annotation as? FloodZoneAnnotation,
               let view = mapView.view(for: flood) as? FloodZoneAnnotationView {
                view.isCardVisible = isZoomedIn
            }
        }
    }

    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        guard let flood = annotation as? FloodZoneAnnotation else { return }

        // If zoomed out, zoom in to show the card
        if mapView.region.span.latitudeDelta >= zoomThreshold {
            let region = MKCoordinateRegion(
                center: flood.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
            mapView.setRegion(region, animated: true)
        }

        // Deselect so the pin can be tapped again
        mapView.deselectAnnotation(flood, animated: false)
    }
}
