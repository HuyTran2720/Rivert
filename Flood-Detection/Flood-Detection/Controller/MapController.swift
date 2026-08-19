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
import SwiftUI

// MARK: - FloodZoneAnnotationView

/// Custom annotation view that renders a circle pin icon with the flood
/// warning image inside. When zoomed in, a MapAnnotationCard appears
/// directly next to the pin — no MapKit callout bubble, no white background.
class FloodZoneAnnotationView: MKAnnotationView {

    static let pinReuseID = "FloodZonePin"

    private var cardHostView: UIView?

    /// Controls whether the info card beside the pin is visible.
    var isCardVisible: Bool = false {
        didSet {
            guard oldValue != isCardVisible else { return }
            UIView.animate(withDuration: 0.2) {
                self.cardHostView?.alpha = self.isCardVisible ? 1 : 0
            }
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = false   // No MapKit callout — we draw our own card
        clipsToBounds = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardHostView?.removeFromSuperview()
        cardHostView = nil
        isCardVisible = false
    }

    // MARK: - Configuration

    /// Sets the pin icon and builds the card for a given flood annotation.
    func configure(with floodAnnotation: FloodZoneAnnotation) {

        // 1. Render the circle pin icon using the PinMarker component
        let pinImage = PinMarker.image(for: floodAnnotation.status)
        self.image = pinImage

        // Offset so the bottom-center of the circle sits at the coordinate
        centerOffset = CGPoint(x: 0, y: -PinMarker.diameter / 2)

        // 2. Build the MapAnnotationCard as a subview
        cardHostView?.removeFromSuperview()

        let card = MapAnnotationCard(
            title: floodAnnotation.zoneName,
            message: floodAnnotation.zoneDescription,
            status: floodAnnotation.status
        )
        let hostingController = UIHostingController(rootView: card)
        hostingController.view.backgroundColor = .clear

        // Size the card to fit its content
        let fittingSize = hostingController.view.systemLayoutSizeFitting(
            CGSize(width: 220, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let cardView = hostingController.view!

        // Position the card to the right of the pin, vertically centered
        let pinWidth = pinImage.size.width
        let pinHeight = pinImage.size.height
        cardView.frame = CGRect(
            x: pinWidth / 2 + 6,
            y: -(fittingSize.height / 2) - (pinHeight / 2),
            width: fittingSize.width,
            height: fittingSize.height
        )
        cardView.alpha = isCardVisible ? 1 : 0

        addSubview(cardView)
        self.cardHostView = cardView
    }

}


// MARK: - MapCoordinator

/// Acts as the MKMapViewDelegate to handle map events.
/// - Provides each annotation with a FloodZoneAnnotationView (custom pin + card).
/// - Toggles card visibility based on zoom level.
class MapCoordinator: NSObject, MKMapViewDelegate {

    /// The latitude-delta threshold below which we consider the map "zoomed in"
    /// and show annotation cards.
    private let zoomThreshold: Double = 0.05

    // MARK: - Pin Appearance

    /// Called by MapKit whenever it needs to display an annotation.
    /// Returns a custom FloodZoneAnnotationView with no MapKit callout.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Only customize our FloodZoneAnnotation pins
        guard let floodAnnotation = annotation as? FloodZoneAnnotation else {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: FloodZoneAnnotationView.pinReuseID
        ) as? FloodZoneAnnotationView

        if annotationView == nil {
            annotationView = FloodZoneAnnotationView(
                annotation: floodAnnotation,
                reuseIdentifier: FloodZoneAnnotationView.pinReuseID
            )
        } else {
            annotationView?.annotation = floodAnnotation
        }

        annotationView?.configure(with: floodAnnotation)

        // Set initial card visibility based on current zoom
        let isZoomedIn = mapView.region.span.latitudeDelta < zoomThreshold
        annotationView?.isCardVisible = isZoomedIn

        return annotationView
    }

    // MARK: - Zoom-Aware Card Visibility

    /// Called every time the visible map region changes (pan, zoom, rotate).
    /// Toggles the MapAnnotationCard visibility on all annotations based
    /// on the current zoom level.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let isZoomedIn = mapView.region.span.latitudeDelta < zoomThreshold

        for annotation in mapView.annotations {
            if let floodAnnotation = annotation as? FloodZoneAnnotation,
               let view = mapView.view(for: floodAnnotation) as? FloodZoneAnnotationView {
                view.isCardVisible = isZoomedIn
            }
        }
    }
}
