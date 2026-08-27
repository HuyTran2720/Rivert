//
//  WaterStatusData.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 13/08/26.
//
import Foundation

struct WaterStatusData {
    var currentLevel: Float
    var riseRate: Float
    var trend: WaterTrend
    var staleness: String
    var timeToBank: String   // pulling this in since SensorState has it
    var status: SafetyStatus
}

extension WaterStatusData {
    init(from sensor: SensorState) {
        self.currentLevel = Float(sensor.levelMM)
        self.riseRate = Float(sensor.rateMMPerMin)
        self.trend = sensor.trend
        self.staleness = sensor.staleness
        self.timeToBank = sensor.timeToBankMin.map { String(format: "%.0f min", $0) } ?? "--"
        self.status = sensor.safetyStatus 
    }
}

enum WaterTrend: String {
    case risingFast
    case droping
    case normal
    
    var WaterTrendIcon: String {
        switch self {
        case .risingFast: return "arrow.up"
        case .droping: return "arrow.down"
        case .normal: return "water.waves"
        }
    }
    
    var WaterTrendName: String {
        switch self {
        case .risingFast: return AppStrings.risingFast
        case .droping: return AppStrings.dropping
        case .normal: return AppStrings.normal
        }
    }
}
