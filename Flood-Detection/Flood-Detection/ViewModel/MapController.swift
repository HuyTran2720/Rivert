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
import FirebaseFirestore

class MapViewModel: ObservableObject {

    @Published var centerOnUser = false
    @Published var needsRefresh = false

    let locationManager = CLLocationManager()

    // Static zones (other areas keep hardcoded data)
    private let staticZones: [FloodZone] = FloodZone.sampleZones

    // Live sensor state from Firestore
    private var sensorState: SensorState?
    private var listener: ListenerRegistration?

    /// All flood zones: static ones + live Legian zone from Firestore.
    var floodZones: [FloodZone] {
        var zones = staticZones

        // Add Legian zone with live status from the sensor
        let legianStatus = sensorState?.safetyStatus ?? .safe
        let description: String
        if let state = sensorState {
            description = AppStrings.waterLevelDesc(mm: String(format: "%.0f", state.levelMM), risk: state.riskState)
        } else {
            description = AppStrings.sensorDataLoading
        }

        let legian = FloodZone(
            name: "Legian",
            status: legianStatus,
            center: CLLocationCoordinate2D(latitude: -8.6900, longitude: 115.1700),
            description: description
        )
        zones.append(legian)
        return zones
    }

    /// Start listening to the Firestore state document for Legian sensor.
    func startListening() {
        let db = Firestore.firestore()
        listener = db.collection("state").document("legian-01")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let snapshot = snapshot, snapshot.exists else { return }

                self.sensorState = try? snapshot.data(as: SensorState.self)
                self.needsRefresh = true
            }
    }

    /// Stop listening when no longer needed.
    func stopListening() {
        listener?.remove()
        listener = nil
    }

    deinit {
        stopListening()
    }

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

    /// Removes all non-user annotations and re-adds with current data.
    func refreshPins(on mapView: MKMapView) {
        let existing = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existing)
        addPins(to: mapView)
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
