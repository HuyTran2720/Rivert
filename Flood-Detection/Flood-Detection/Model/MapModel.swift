//
//  MapModel.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 06/08/26.
//
//  MODEL — Contains all data structures and sample data for the map.
//  This is the "M" in MVC: pure data with no UI or control logic.
//

import UIKit
import MapKit



// MARK: - Flood Zone (Data Model)

/// A single flood-prone area on the map.
/// Each zone has a name, risk level, location, and a text description.
struct FloodZone: Identifiable {
    let id = UUID()
    let name: String
    let status: SafetyStatus
    let center: CLLocationCoordinate2D   // Where to place the pin
    let description: String
}

// MARK: - Flood Zone Annotation

/// A custom map annotation that carries extra flood zone metadata.
/// Used so the map delegate can access risk level and description when
/// rendering pins and handling taps.
class FloodZoneAnnotation: MKPointAnnotation {
    var status: SafetyStatus = .safe
    var zoneName: String = ""
    var zoneDescription: String = ""
}

// MARK: - Map Configuration

/// Holds the default map region (centered on Bali).
struct MapConfig {
    static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -8.4095, longitude: 115.1889),
        span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
    )
}

// MARK: - Sample Data

/// Hardcoded flood zone data for Bali.
/// In a real app this would come from an API or database.
extension FloodZone {

    static let sampleZones: [FloodZone] = [

        // --- High Risk Zones ---

        FloodZone(
            name: "Denpasar",
            status: .danger,
            center: CLLocationCoordinate2D(latitude: -8.6500, longitude: 115.2167),
            description: "Urban flooding due to drainage overflow. High population density area."
        ),

        FloodZone(
            name: "Kuta",
            status: .danger,
            center: CLLocationCoordinate2D(latitude: -8.7200, longitude: 115.1700),
            description: "Coastal flooding risk. Low-lying terrain near beach areas."
        ),

        // --- Medium Risk Zones ---

        FloodZone(
            name: "Ubud",
            status: .caution,
            center: CLLocationCoordinate2D(latitude: -8.5069, longitude: 115.2625),
            description: "River valley flooding during heavy rains. Moderate terrain elevation."
        ),

        FloodZone(
            name: "Gianyar",
            status: .caution,
            center: CLLocationCoordinate2D(latitude: -8.5415, longitude: 115.3233),
            description: "Seasonal flood risk near rice terraces and river systems."
        ),

        FloodZone(
            name: "Tabanan",
            status: .caution,
            center: CLLocationCoordinate2D(latitude: -8.5410, longitude: 115.1250),
            description: "Agricultural flooding from river overflow in the rainy season."
        ),

        // --- Low Risk Zones ---

        FloodZone(
            name: "Singaraja",
            status: .safe,
            center: CLLocationCoordinate2D(latitude: -8.1120, longitude: 115.0882),
            description: "Elevated terrain with good drainage. Minimal flood history."
        ),

        FloodZone(
            name: "Karangasem",
            status: .safe,
            center: CLLocationCoordinate2D(latitude: -8.4486, longitude: 115.6127),
            description: "Highland area near Mount Agung. Well-drained volcanic soil."
        ),

        FloodZone(
            name: "Bangli",
            status: .safe,
            center: CLLocationCoordinate2D(latitude: -8.4544, longitude: 115.3500),
            description: "Central highland region. Elevated terrain provides natural flood protection."
        ),
    ]
}
