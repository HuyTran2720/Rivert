//
//  WaterStatusData.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 13/08/26.
//
struct WaterStatusData {
    var currentLevel: Float
    var riseRate: Float
    var trend:  waterTrend
    var staleness: String
}

enum waterTrend: String {
    case risingFast = "Rising Fast"
    case rising = " Rising"
    case normal = "Normal"
    
    var systemImageName: String {
        switch self {
        case .risingFast: return "arrow.up"
        case .rising: return "arrow.up"
        case .normal: return "water.waves"
        }
    }
}
