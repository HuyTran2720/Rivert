//
//  WaterStatusData.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 13/08/26.
//
struct WaterStatusData {
<<<<<<< HEAD:Flood-Detection/Flood-Detection/Model/WaterStatusModel.swift
    var currentLevel: Float
    var riseRate: Float
    var trend:  waterTrend
    var staleness: String
}

enum waterTrend: String {
    case risingFast = "Rising Fast"
    case rising = " Rising"
    case normal = "Normal"
=======
    let currentLevel: Float
    let riseRate: Float
    let trend:  WaterTrend
    let staleness: String
}

enum WaterTrend: String {
    case risingFast
    case dropingFast
    case normal
>>>>>>> Feat-NewMap:Flood-Detection/Flood-Detection/Model/WaterStatusData.swift
    
    var systemImageName: String {
        switch self {
        case .risingFast: return "arrow.up"
        case .rising: return "arrow.up"
        case .normal: return "water.waves"
        }
    }
}
