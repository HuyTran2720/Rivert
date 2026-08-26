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
    }
}
