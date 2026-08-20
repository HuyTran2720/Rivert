//
//  MapView.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 06/08/26.
//
//  VIEW — A thin SwiftUI wrapper around MKMapView.
//  This is the "V" in MVC: it only creates the map and places pins on it.
//  All interaction logic lives in MapCoordinator (Controller).
//  All data lives in MapModel (Model).
//

import SwiftUI
import MapKit

struct MapKitView: UIViewRepresentable {

    /// The list of flood zones to display as pins on the map.
    private let floodZones: [FloodZone] = FloodZone.sampleZones

    // MARK: - Coordinator

    /// Creates the controller (delegate) that handles map interactions.
    func makeCoordinator() -> MapCoordinator {
        MapCoordinator()
    }

    // MARK: - Create the Map

    /// Called once when the view first appears.
    /// Sets the initial map region and adds a pin for each flood zone.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)

        // Wire up the controller as the map's delegate
        mapView.delegate = context.coordinator

        // Center the map on Bali using the config from MapModel
        mapView.setRegion(MapConfig.defaultRegion, animated: false)

        // Add a clickable pin annotation for every flood zone
        addFloodZonePins(to: mapView)

        return mapView
    }

    /// Called whenever SwiftUI state changes. No dynamic updates needed yet.
    func updateUIView(_ uiView: MKMapView, context: Context) {}

    // MARK: - Helpers

    /// Converts each FloodZone into a map annotation and adds it to the map.
    private func addFloodZonePins(to mapView: MKMapView) {
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
}

// MARK: - Main Map View
struct MapView: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapKitView()
            
            InformationCard(status: .safe)
                .padding(.bottom, 40)
                .padding(.trailing, 16)
        }
    }
}

#Preview {
    MapView()
        .ignoresSafeArea()
}
