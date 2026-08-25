//
//  SensorState.swift
//  Flood-Detection
//
//  Firestore document model for the "state" collection.
//  Maps directly to the fields in the "legian-01" document.
//

import Foundation
import FirebaseFirestore

struct SensorState: Codable {
    @DocumentID var id: String?
    var siteId: String
    var calibrated: Bool
    var levelMM: Double
    var rateMMPerMin: Double
    var freeboardMM: Double
    var riskState: String
    var staleness: String
    var timeToBankMin: Double?
    var computedAt: Timestamp
    var latestReadingAt: Timestamp

    // Convert Timestamp to Date for display
    var computedDate: Date { computedAt.dateValue() }
    var latestReadingDate: Date { latestReadingAt.dateValue() }

    // Convert the Firestore riskState string to our SafetyStatus enum
    var safetyStatus: SafetyStatus {
        switch riskState {
        case "danger": return .danger
        case "caution": return .caution
        case "safe", "normal": return .safe
        default: return .safe
        }
    }

    // Convert rateMMPerMin into a waterTrend
    var trend: WaterTrend {
        if rateMMPerMin > 10 {
            return .risingFast
        } else if rateMMPerMin > 0 {
            return .droping
        } else {
            return .normal
        }
    }
}
