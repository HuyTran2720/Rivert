//
//  SafetyStatusModel.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 14/08/26.
//

import UIKit

enum SafetyStatus: String, CaseIterable {
    case danger = "Rising Fast"
    case caution = "Rising Medium"
    case safe = "Safe"

    /// The color used for the map pin marker.
    var pinTintColor: UIColor {
        switch self {
        case .danger: return UIColor(red: 0.90, green: 0.22, blue: 0.21, alpha: 1.0)
        case .caution: return UIColor(red: 0.98, green: 0.75, blue: 0.18, alpha: 1.0)
        case .safe:    return UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        }
    }

    /// An emoji circle that visually indicates the risk status.
    var statusEmoji: String {
        switch self {
        case .danger: return "🔴"
        case .caution: return "🟡"
        case .safe:    return "🟢"
        }
    }

    /// Maps Firestore's `riskState` field ("safe" / "caution" / "danger")
    /// to this enum. Kept separate from `rawValue` because `rawValue` here
    /// is the *display* string ("Rising Fast", etc.), not the backend value —
    /// those are two different vocabularies for the same three states.
    ///
    /// Falls back to `.safe` ONLY as a last resort if the backend sends
    /// something unrecognized — but logs so a bad value doesn't fail silently.
    init(firestoreValue: String) {
        switch firestoreValue.lowercased() {
        case "danger":
            self = .danger
        case "caution":
            self = .caution
        case "safe":
            self = .safe
        default:
            assertionFailure("Unrecognized riskState from Firestore: \(firestoreValue)")
            self = .safe
        }
    }
}
