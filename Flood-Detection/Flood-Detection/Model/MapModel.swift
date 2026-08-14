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

// MARK: - Risk Level

/// Represents how severe the flood risk is for a given zone.
/// Each case carries a display label, a pin color, and a status emoji.
enum RiskLevel: String, CaseIterable {
    case high   = "High Risk"
    case medium = "Medium Risk"
    case low    = "Low Risk"

    /// The color used for the map pin marker.
    var pinTintColor: UIColor {
        switch self {
        case .high:   return UIColor(red: 0.90, green: 0.22, blue: 0.21, alpha: 1.0)
        case .medium: return UIColor(red: 0.98, green: 0.75, blue: 0.18, alpha: 1.0)
        case .low:    return UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        }
    }

<<<<<<< HEAD
    /// SF Symbol name for the status indicator icon (circle.fill variants).
    var statusIcon: String {
        switch self {
        case .high:   return "exclamationmark.circle.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .low:    return "checkmark.circle.fill"
        }
    }

    /// SF Symbol name for the glyph displayed inside the map pin marker.
    var glyphIcon: String {
        switch self {
        case .high:   return "flame.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .low:    return "checkmark"
=======
    /// An emoji circle that visually indicates the risk status.
    var statusEmoji: String {
        switch self {
        case .high:   return "🔴"
        case .medium: return "🟡"
        case .low:    return "🟢"
>>>>>>> FEAT-Model
        }
    }
}

// MARK: - Flood Zone (Data Model)

/// A single flood-prone area on the map.
/// Each zone has a name, risk level, location, and a text description.
struct FloodZone: Identifiable {
    let id = UUID()
    let name: String
    let riskLevel: RiskLevel
    let center: CLLocationCoordinate2D   // Where to place the pin
    let description: String
}

// MARK: - Flood Zone Annotation

/// A custom map annotation that carries extra flood zone metadata.
/// Used so the map delegate can access risk level and description when
/// rendering pins and handling taps.
class FloodZoneAnnotation: MKPointAnnotation {
    var riskLevel: RiskLevel = .low
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
            riskLevel: .high,
            center: CLLocationCoordinate2D(latitude: -8.6500, longitude: 115.2167),
            description: "Urban flooding due to drainage overflow. High population density area."
        ),

        FloodZone(
            name: "Kuta",
            riskLevel: .high,
            center: CLLocationCoordinate2D(latitude: -8.7200, longitude: 115.1700),
            description: "Coastal flooding risk. Low-lying terrain near beach areas."
        ),

        // --- Medium Risk Zones ---

        FloodZone(
            name: "Ubud",
            riskLevel: .medium,
            center: CLLocationCoordinate2D(latitude: -8.5069, longitude: 115.2625),
            description: "River valley flooding during heavy rains. Moderate terrain elevation."
        ),

        FloodZone(
            name: "Gianyar",
            riskLevel: .medium,
            center: CLLocationCoordinate2D(latitude: -8.5415, longitude: 115.3233),
            description: "Seasonal flood risk near rice terraces and river systems."
        ),

        FloodZone(
            name: "Tabanan",
            riskLevel: .medium,
            center: CLLocationCoordinate2D(latitude: -8.5410, longitude: 115.1250),
            description: "Agricultural flooding from river overflow in the rainy season."
        ),

        // --- Low Risk Zones ---

        FloodZone(
            name: "Singaraja",
            riskLevel: .low,
            center: CLLocationCoordinate2D(latitude: -8.1120, longitude: 115.0882),
            description: "Elevated terrain with good drainage. Minimal flood history."
        ),

        FloodZone(
            name: "Karangasem",
            riskLevel: .low,
            center: CLLocationCoordinate2D(latitude: -8.4486, longitude: 115.6127),
            description: "Highland area near Mount Agung. Well-drained volcanic soil."
        ),

        FloodZone(
            name: "Bangli",
            riskLevel: .low,
            center: CLLocationCoordinate2D(latitude: -8.4544, longitude: 115.3500),
            description: "Central highland region. Elevated terrain provides natural flood protection."
        ),
    ]
}
<<<<<<< HEAD

struct map {
    let longitude: String
    let latitude: String
    let placeName: String
    let mapStatus: SafetyStatus
}
=======
>>>>>>> FEAT-Model
