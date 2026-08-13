//
//  MapController.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 06/08/26.
//
//  CONTROLLER — Handles all map interaction logic as the MKMapViewDelegate.
//  This is the "C" in MVC: it responds to user actions on the map (pin taps,
//  callout button taps) and decides what to show.
//

import UIKit
import MapKit

// MARK: - MapCoordinator

/// Acts as the MKMapViewDelegate to handle map events.
/// - Configures how each pin (annotation) looks on the map.
/// - Handles what happens when the user taps a pin's detail button.
class MapCoordinator: NSObject, MKMapViewDelegate {

    // MARK: - Pin Appearance

    /// Called by MapKit whenever it needs to display an annotation.
    /// We customize each pin with the flood zone's risk color and emoji.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Only customize our FloodZoneAnnotation pins (skip the user's location dot, etc.)
        guard let floodAnnotation = annotation as? FloodZoneAnnotation else {
            return nil
        }

        let reuseID = "FloodZoneMarker"

        // Try to reuse an existing annotation view for better scroll performance
        var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView

        if markerView == nil {
            // First time — create a new marker view
            markerView = MKMarkerAnnotationView(annotation: floodAnnotation, reuseIdentifier: reuseID)
            markerView?.canShowCallout = true   // Show the popup bubble when tapped

            // Add an info button (ℹ️) on the right side of the callout
            let detailButton = UIButton(type: .detailDisclosure)
            markerView?.rightCalloutAccessoryView = detailButton

            // Add a risk-status emoji on the left side of the callout
            let statusLabel = UILabel()
            statusLabel.font = UIFont.systemFont(ofSize: 28)
            statusLabel.text = floodAnnotation.riskLevel.statusEmoji
            markerView?.leftCalloutAccessoryView = statusLabel
        } else {
            // Reusing — just update which annotation this view represents
            markerView?.annotation = floodAnnotation
        }

        // Color the pin marker based on risk level (red / yellow / green)
        markerView?.markerTintColor = floodAnnotation.riskLevel.pinTintColor
        markerView?.glyphText = glyphForRisk(floodAnnotation.riskLevel)
        markerView?.titleVisibility = .adaptive

        return markerView
    }

    // MARK: - Pin Detail Tap

    /// Called when the user taps the info button (ℹ️) inside a pin's callout.
    /// Shows an alert with the full zone name, risk level, and description.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        guard let floodAnnotation = view.annotation as? FloodZoneAnnotation else { return }

        // Build the alert message
        let alert = UIAlertController(
            title: "\(floodAnnotation.riskLevel.statusEmoji) \(floodAnnotation.zoneName)",
            message: """
            Risk Level: \(floodAnnotation.riskLevel.rawValue)

            \(floodAnnotation.zoneDescription)
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        // Present the alert on the topmost view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(alert, animated: true)
        }
    }

    // MARK: - Helpers

    /// Returns a short glyph string to display inside the map pin marker.
    private func glyphForRisk(_ risk: RiskLevel) -> String {
        switch risk {
        case .high:   return "🔥"
        case .medium: return "⚠️"
        case .low:    return "✓"
        }
    }
}
