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
    case rising
    case risingFast
    case falling 
    case fallingFast
}
