//
//  DashboardDataModel.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 14/08/26.
//

import SwiftUI

struct DashboardData  {
    var location: MapData? = nil
    var weather: WeatherState? = nil
    var waterStatus: WaterStatusData? = nil
    var dashboardStatus: SafetyStatus {
        location?.mapStatus ?? .safe
    }
}
