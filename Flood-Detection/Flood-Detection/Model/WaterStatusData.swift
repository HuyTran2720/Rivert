//
//  WaterStatusData.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 13/08/26.
//
struct WaterStatusData {
    var currentLevel: Float
    var riseRate: Float
    var trend:  WaterTrend
    var staleness: String
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
        case .risingFast: return "Rising Fast"
        case .droping: return "Droping"
        case .normal: return "Normal"
        }
    }
}
