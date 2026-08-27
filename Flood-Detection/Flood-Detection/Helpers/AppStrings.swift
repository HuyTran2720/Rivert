//
//  AppStrings.swift
//  Flood-Detection
//
//  Simple in-app localization helper.
//  Reads the "appLanguage" key from UserDefaults (@AppStorage).
//

import Foundation

struct AppStrings {
    
    private static var lang: String {
        UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }
    
    // MARK: - SafetyStatusCard
    
    static var safe: String { lang == "id" ? "AMAN" : "SAFE" }
    static var caution: String { lang == "id" ? "WASPADA" : "CAUTION" }
    static var danger: String { lang == "id" ? "BAHAYA" : "DANGER" }
    
    static var safeMessage: String {
        lang == "id" ? "Sungai dalam kondisi normal." : "River is within normal levels."
    }
    static var cautionMessage: String {
        lang == "id" ? "Risiko banjir lebih tinggi dalam satu jam ke depan. Bersiaplah!" : "Higher flood risk is expected within the next hour. Be prepared!"
    }
    static var dangerMessage: String {
        lang == "id" ? "Sungai telah meluap. Hindari area ini!" : "The river has overspilled. Avoid this area!"
    }
    
    static func statusTitle(for status: SafetyStatus) -> String {
        switch status {
        case .safe: return safe
        case .caution: return caution
        case .danger: return danger
        }
    }
    
    static func statusMessage(for status: SafetyStatus) -> String {
        switch status {
        case .safe: return safeMessage
        case .caution: return cautionMessage
        case .danger: return dangerMessage
        }
    }
    
    // MARK: - InformationCard
    
    static var riverWaterLevel: String {
        lang == "id" ? "Tinggi Muka Air" : "River Water Level"
    }
    static var rateOfWaterRise: String {
        lang == "id" ? "Laju Kenaikan Air" : "Rate of Water Rise"
    }
    static var rateDescription: String {
        lang == "id" ? "Seberapa cepat air sungai naik" : "How fast the river water level is rising"
    }
    static var measuredBySensor: String {
        lang == "id" ? "Diukur oleh sensor sungai" : "Measured by river sensor"
    }
    static var updatedAgo: String {
        lang == "id" ? "Diperbarui 2 menit lalu" : "Updated 2 min ago"
    }
    
    // MARK: - TimeCard
    
    static var riverOverflow: String {
        lang == "id" ? "Luapan Sungai" : "River Overflow"
    }
    static var floodDetected: String {
        lang == "id" ? "Banjir Terdeteksi" : "Flood Detected"
    }
    static var noFloodDetected: String {
        lang == "id" ? "Tidak ada banjir" : "No flood detected"
    }
    
    // MARK: - WaterTrend
    
    static var risingFast: String {
        lang == "id" ? "Naik Cepat" : "Rising Fast"
    }
    static var dropping: String {
        lang == "id" ? "Menurun" : "Dropping"
    }
    static var normal: String {
        lang == "id" ? "Normal" : "Normal"
    }
    
    // MARK: - MapAnnotationCard
    
    static var sensorDataLoading: String {
        lang == "id" ? "Memuat data sensor…" : "Sensor data loading…"
    }
    static func waterLevelDesc(mm: String, risk: String) -> String {
        lang == "id" ? "Tinggi air: \(mm) mm — \(risk)" : "Water level: \(mm) mm — \(risk)"
    }
}
