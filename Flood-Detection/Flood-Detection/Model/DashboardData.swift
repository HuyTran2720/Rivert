//
//  DashboardDataModel.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 14/08/26.
//

import SwiftUI

struct DashboardData  {
    let location: MapData
    let weather: WeatherModel
    let waterStatus: WaterStatusData
    var dashboardStatus: SafetyStatus {
        location.mapStatus
    }
}
