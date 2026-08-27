//
//  DashboardViewModel.swift
//  Flood-Detection
//

import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
final class DashboardViewModel: ObservableObject {
    
    @Published var data = DashboardData()
    
    private var listener: ListenerRegistration?
    
    // MARK: - InformationCard
    
    var status: SafetyStatus {
        data.waterStatus?.status ?? .safe
    }
    
    private var sensorStatus: SafetyStatus = .safe
    
    var currentLevel: Float {
        (data.waterStatus?.currentLevel ?? 0)/10
    }
    
    var rateValue: String {
        guard let rate = data.waterStatus?.riseRate else { return "0" }
        return String(format: "%.0f", rate)
    }
    
    var trend: WaterTrend {
        data.waterStatus?.trend ?? .normal
    }
    
    // MARK: - TimeCard
    
    var timeToBank: String {
        data.waterStatus?.timeToBank ?? "--"
    }
    
    // MARK: - WeatherCard

    /// Site-local clock. BMKG stamps its slots in UTC, so without this
    /// the strip would label them in whatever zone the phone is set to
    /// and a traveller would see the wrong hours for Legian.
    private static let slotHourFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "H"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Asia/Makassar") ?? .current
        return f
    }()

    /// Current slot first, then the next four. Empty until refreshWeather
    /// has run — the card renders its own placeholder in that case.
    var weatherSlots: [WeatherSlotDisplay] {
        guard let forecast = data.weather?.forecast else { return [] }
        return forecast.prefix(5).map { slot in
            WeatherSlotDisplay(
                id: slot.date,
                hourLabel: Self.slotHourFormatter.string(from: slot.date),
                tempC: Int(slot.tempC.rounded()),
                description: slot.description,
                icon: WeatherIcon.from(description: slot.description)
            )
        }
    }

    // MARK: - Firestore listener
    
    func startListening() {
        print("🔵 startListening called")
        let db = Firestore.firestore()
        listener = db.collection("state").document("legian-01")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                
                if let error {
                    print("🔴 Firestore error: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot, snapshot.exists else {
                    print("🟡 Document does not exist at state/legian-01")
                    return
                }
                
                print("🟢 Raw document data: \(snapshot.data() ?? [:])")
                
                do {
                    let sensor = try snapshot.data(as: SensorState.self)
                    print("🟢 Decoded successfully: \(sensor)")
                    self.updateSensor(sensor)
                } catch {
                    print("🔴 Decode error: \(error)")
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func updateSensor(_ sensor: SensorState) {
        data.waterStatus = WaterStatusData(from: sensor)
        sensorStatus = sensor.safetyStatus
        data.weather = sensor.weather
    }
}
