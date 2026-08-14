//
//  WaterStatusData.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 13/08/26.
//
struct WaterStatusData {
    let currentLevel: Float
    let riseRate: Float
    let trend:  waterTrend
    let staleness: String
}

enum waterTrend: String {
    case risingFast
    case dropingFast
    case normal
    
    var systemImageName: String {
        switch self {
        case .risingFast: return "arrow.up"
        case .dropingFast: return "arrow.down"
        case .normal: return "water.waves"
        }
    }
}
