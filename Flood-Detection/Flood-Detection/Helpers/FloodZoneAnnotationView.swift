//
//  FloodZoneAnnotationView.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 06/08/26.
//

import UIKit
import MapKit
import SwiftUI

/// Custom annotation view that shows a pin icon and a card beside it.
class FloodZoneAnnotationView: MKAnnotationView {

    static let reuseID = "FloodZonePin"
    private var cardHostView: UIView?

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
        canShowCallout = false
        clipsToBounds = false
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardHostView?.removeFromSuperview()
        cardHostView = nil
        isCardVisible = false
    }

    /// Sets the pin icon and builds the info card.
    func configure(with annotation: FloodZoneAnnotation) {
        let pinImage = PinMarker.image(for: annotation.status)
        self.image = pinImage
        centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)

        // Build card
        cardHostView?.removeFromSuperview()

        let card = MapAnnotationCard(
            title: annotation.zoneName,
            message: annotation.zoneDescription,
            status: annotation.status
        )
        let host = UIHostingController(rootView: card)
        host.view.backgroundColor = .clear

        let size = host.view.systemLayoutSizeFitting(
            CGSize(width: 220, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let cardView = host.view!
        let circleCenter = (PinMarker.circleSize + PinMarker.borderWidth) / 2
        cardView.frame = CGRect(
            x: pinImage.size.width / 2 + 25,
            y: circleCenter - size.height / 2,
            width: size.width,
            height: size.height
        )
        cardView.alpha = isCardVisible ? 1 : 0

        addSubview(cardView)
        self.cardHostView = cardView
    }
}
